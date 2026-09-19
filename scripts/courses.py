"""Contributor-facing course commands. Course front matter is the only index data source."""

import argparse
import json
import os
import posixpath
import re
import subprocess
import sys
import tempfile
import unicodedata
from collections import defaultdict
from decimal import Decimal, InvalidOperation
from pathlib import Path
from urllib.parse import unquote, urlsplit

try:
    import yaml
except ImportError:
    print("缺少 PyYAML/MkDocs。请先运行 npm run setup。", file=sys.stderr)
    raise SystemExit(1)


CATEGORIES = ("基础课程", "专业课程", "公共课程", "毕业相关")
SEMESTERS = ("大一上", "大一下", "大一上暑假", "大一下暑假", "大二上", "大二下",
             "大二上暑假", "大二下暑假", "大三上", "大三下", "大三上暑假", "大三下暑假",
             "大四上", "大四下", "大四上暑假", "大四下暑假")
BEGIN = "<!-- BEGIN GENERATED COURSES -->"
END = "<!-- END GENERATED COURSES -->"
NAV_BEGIN = "  # BEGIN GENERATED COURSES"
NAV_END = "  # END GENERATED COURSES"
BAD_NAME = re.compile(r'[<>:"/\\|?*\x00-\x1f]')
LINK = re.compile(r'!?\[[^\]]*\]\((?:<([^>]+)>|([^\s)]+))(?:\s+[^)]*)?\)')
LEGACY_ANCHORS = {
    "CS": ("大二上", "大三上", "大三下"),
    "ECE": ("大二上", "大二下"),
    "EI": ("大二上", "大二下"),
    "EE": ("大一下", "大三下"),
}


class CourseError(Exception):
    pass


def scalar(value):
    return "" if value is None else str(value).strip()


def name_key(value):
    return unicodedata.normalize("NFKC", value).casefold()


def check_name(value):
    if not value or value in (".", "..") or value.rstrip(" .") != value or BAD_NAME.search(value):
        raise CourseError(f"非法或空课程名称：{value!r}")
    if name_key(value).split(".")[0] in {"con", "prn", "aux", "nul", *(f"com{i}" for i in range(1, 10)), *(f"lpt{i}" for i in range(1, 10))}:
        raise CourseError(f"Windows 保留文件名：{value}")


def read_metadata(text, path):
    match = re.match(r"\A---\r?\n(.*?)\r?\n---\r?\n", text, re.S)
    if not match:
        raise CourseError(f"缺少 YAML front matter：{path}")
    try:
        data = yaml.safe_load(match.group(1))
    except yaml.YAMLError as exc:
        raise CourseError(f"无效 YAML：{path}: {exc}") from exc
    if not isinstance(data, dict):
        raise CourseError(f"front matter 必须是对象：{path}")
    return data, text[match.end():]


def to_markdown(data, body):
    return "---\n" + yaml.safe_dump(data, allow_unicode=True, sort_keys=False, width=1000) + "---\n" + body


def validate_offering(offering, path, majors, legacy=True):
    if not isinstance(offering, dict):
        raise CourseError(f"offering 必须是对象：{path}")
    for key in ("major", "semester", "credits"):
        if key not in offering:
            raise CourseError(f"缺少 offering.{key}：{path}")
    major, semester, credits = (scalar(offering[k]) for k in ("major", "semester", "credits"))
    if not major or not semester:
        raise CourseError(f"专业与学期不能为空：{path}")
    if major not in majors and major not in ("通用", "未标注"):
        raise CourseError(f"未知专业 {major}：{path}；请先更新 config/course-majors.json")
    if semester not in SEMESTERS and semester != "未注明":
        raise CourseError(f"无效学期 {semester}：{path}")
    if not legacy and (major == "未标注" or semester == "未注明"):
        raise CourseError("新课程/新增 offering 不接受“未标注／未注明”，请填写真实专业和学期")
    if credits:
        try:
            number = Decimal(credits)
            if not number.is_finite() or number <= 0:
                raise InvalidOperation
        except InvalidOperation:
            raise CourseError(f"无效学分 {credits}：{path}") from None
    elif not legacy:
        raise CourseError(f"学分不能为空：{path}")
    for key in ("requirement", "resources"):
        if key in offering and not isinstance(offering[key], (str, type(None))):
            raise CourseError(f"offering.{key} 必须是文本：{path}")
    return major, semester


def load_courses(root, majors, overrides=None):
    course_dir = root / "docs" / "课程"
    if not course_dir.is_dir():
        raise CourseError(f"缺少课程目录：{course_dir}")
    overrides = overrides or {}
    paths = {p for p in course_dir.glob("*.md")} | set(overrides)
    seen = {}
    courses = []
    warnings = []
    for path in sorted(paths, key=lambda p: name_key(p.name)):
        check_name(path.stem)
        key = name_key(path.stem)
        if key in seen:
            raise CourseError(f"大小写/Unicode 等价文件名冲突：{seen[key]} 与 {path}")
        seen[key] = path
        text = overrides[path] if path in overrides else path.read_text(encoding="utf-8")
        data, body = read_metadata(text, path)
        for field in ("title", "category", "offerings"):
            if field not in data:
                raise CourseError(f"缺少 front matter.{field}：{path}")
        if data["title"] != path.stem:
            raise CourseError(f"课程标题与文件名不一致：{path}")
        if data["category"] not in CATEGORIES:
            raise CourseError(f"无效分类 {data['category']}：{path}")
        if not isinstance(data["offerings"], list) or not data["offerings"]:
            raise CourseError(f"offerings 不能为空：{path}")
        pairs = set()
        for offering in data["offerings"]:
            pair = validate_offering(offering, path, majors)
            if pair in pairs:
                raise CourseError(f"重复 offering {pair}：{path}")
            pairs.add(pair)
            if pair[0] == "未标注" or pair[1] == "未注明":
                warnings.append(f"历史待补全：{path.name}：{pair[0]}／{pair[1]}")
        courses.append({"path": path, "data": data, "body": body})
    return courses, warnings


def validate_links(changes, root):
    docs = root / "docs"
    relevant = ("课程", "本科生课程", "学院汇总")
    pages = {p for p in docs.rglob("*.md") if p.relative_to(docs).parts[0] in relevant}
    pages |= {p for p in changes if p.suffix == ".md" and p.is_relative_to(docs) and p.relative_to(docs).parts[0] in relevant}
    for path in sorted(pages):
        content = changes[path] if path in changes else path.read_text(encoding="utf-8")
        for match in LINK.finditer(content):
            raw = (match.group(1) or match.group(2)).strip()
            if raw.startswith(("#", "//")) or re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", raw):
                continue
            target = unquote(urlsplit(raw).path).replace("\\", "/")
            if not target:
                continue
            dest = (path.parent / target).resolve()
            if not dest.is_relative_to(docs.resolve()) or not (dest.exists() or dest in changes or (dest / "index.md").exists() or (dest / "index.md") in changes):
                raise CourseError(f"无效站内链接：{path.relative_to(root)} -> {raw}")


def row_link(course, page):
    target = course["path"].relative_to(page.parent).as_posix() if course["path"].is_relative_to(page.parent) else posixpath.relpath(course["path"].as_posix(), page.parent.as_posix())
    target = re.sub(r"[%#()? \[\]]", lambda m: f"%{ord(m.group()):02X}", target)
    label = course["data"]["title"].replace("[", "\\[").replace("]", "\\]").replace("|", "\\|")
    return f"[{label}]({target})"


def cell(value):
    return scalar(value).replace("|", "\\|").replace("\n", " ")


def format_values(offerings, field):
    if len(offerings) == 1:
        return cell(offerings[0].get(field))
    values = []
    for offering in sorted(offerings, key=lambda item: (item["major"], item["semester"])):
        value = cell(offering.get(field))
        if value:
            label = offering["major"] + (f"·{offering['semester']}" if sum(x["major"] == offering["major"] for x in offerings) > 1 else "")
            values.append(f"{label}：{value}")
    return "；".join(values)


def table(courses, page, major=None, semester=None):
    rows = ["|课程|学分|学期|修读情况|资料情况|", "|:--|:--|:--|:--|:--|"]
    for course in sorted(courses, key=lambda item: name_key(item["data"]["title"])):
        offerings = [o for o in course["data"]["offerings"] if (major is None or o["major"] == major) and (semester is None or o["semester"] == semester)]
        if not offerings:
            continue
        rows.append("|" + "|".join([row_link(course, page), *[format_values(offerings, field) for field in ("credits", "semester", "requirement", "resources")]]) + "|")
    if len(rows) == 2:
        rows.append("|暂无课程记录|||||")
    return "\n".join(rows)


def pending(courses, page):
    waiting = [c for c in courses if any(o["major"] == "未标注" or o["semester"] == "未注明" for o in c["data"]["offerings"])]
    if not waiting:
        return ""
    return "\n\n## 信息待补全\n\n以下历史记录的专业或学期尚未核定，欢迎通过课程维护命令补充。\n\n" + table(waiting, page)


def replace_region(path, content, start, end, replacement):
    if content.count(start) != 1 or content.count(end) != 1:
        raise CourseError(f"缺少或重复生成区域标记：{path}")
    i = content.index(start) + len(start)
    j = content.index(end)
    if i > j:
        raise CourseError(f"生成区域标记顺序错误：{path}")
    return content[:i] + "\n" + replacement.rstrip() + "\n" + content[j:]


def anchor(major, semester):
    year = "一二三四".index(semester[1]) + 1
    season = "fall" if "上" in semester else "spring"
    suffix = "-summer" if "暑假" in semester else ""
    return f"{major.lower()}-year{year}-{season}{suffix}"


def nav_text(courses, majors):
    lines = ["  - 本科生课程:", "    - 概览: 本科生课程/index.md",
             "    - 体育选课: 本科生课程/选课信息/physics.md",
             "    - CET-4&6: 本科生课程/CET/index.md", "    - 分类概览:"]
    for category in CATEGORIES:
        lines.append(f"      - {category}: 本科生课程/{category}/index.md")
    lines.append("    - 按学院与专业速查:")
    colleges = list(dict.fromkeys(value["college"] for value in majors.values()))
    for college in colleges:
        lines.append(f"      - {college}:")
        for code, item in majors.items():
            if item["college"] == college:
                lines.append(f"        - {item['name']}: 学院汇总/{college}/{code}.md")
    lines.append("    - 课程目录:")
    for category in CATEGORIES:
        lines.append(f"      - {category}:")
        for course in sorted((c for c in courses if c["data"]["category"] == category), key=lambda c: name_key(c["data"]["title"])):
            title = course["data"]["title"]
            lines.append(f"        - {json.dumps(title, ensure_ascii=False)}: {json.dumps('课程/' + title + '.md', ensure_ascii=False)}")
    return "\n".join(lines)


def generate_changes(root, courses, majors):
    changes = {}
    docs = root / "docs"
    overview = docs / "本科生课程" / "index.md"
    sections = ["## " + category + "\n\n" + table([c for c in courses if c["data"]["category"] == category], overview) for category in CATEGORIES]
    overview_content = "\n\n".join(sections) + pending(courses, overview)
    changes[overview] = replace_region(overview, overview.read_text(encoding="utf-8"), BEGIN, END, overview_content)
    for category in CATEGORIES:
        page = docs / "本科生课程" / category / "index.md"
        original = page.read_text(encoding="utf-8") if page.exists() else f"# {category}概览\n\n欢迎补充课程信息。\n\n{BEGIN}\n{END}\n"
        subset = [c for c in courses if c["data"]["category"] == category]
        changes[page] = replace_region(page, original, BEGIN, END, table(subset, page) + pending(subset, page))
    for major, info in majors.items():
        page = docs / "学院汇总" / info["college"] / f"{major}.md"
        original = page.read_text(encoding="utf-8") if page.exists() else f"# {info['name']}专业课程概览\n\n{BEGIN}\n{END}\n"
        semesters = set(LEGACY_ANCHORS.get(major, ()))
        semesters.update(o["semester"] for c in courses for o in c["data"]["offerings"] if o["major"] == major)
        parts = []
        for semester in sorted(semesters, key=lambda value: (SEMESTERS.index(value) if value in SEMESTERS else 999)):
            parts.append(f"## {semester} {{#{anchor(major, semester)}}}\n\n" + table(courses, page, major, semester))
        changes[page] = replace_region(page, original, BEGIN, END, "\n\n".join(parts))
    config = root / "mkdocs.yml"
    changes[config] = replace_region(config, config.read_text(encoding="utf-8"), NAV_BEGIN, NAV_END, nav_text(courses, majors))
    return changes


def write_changes(changes):
    changed = {path: content for path, content in changes.items() if not path.exists() or path.read_text(encoding="utf-8") != content}
    staged = []
    before = {path: path.read_bytes() if path.exists() else None for path in changed}
    completed = []
    try:
        for path, content in changed.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="\n", dir=path.parent, prefix=".icicles-", delete=False) as handle:
                handle.write(content)
                staged.append(Path(handle.name))
        for path, temporary in zip(changed, staged):
            if before[path] is None:
                os.link(temporary, path)  # Fails instead of overwriting if another writer created it.
            else:
                os.replace(temporary, path)
            completed.append(path)
    except Exception:
        for path in completed:
            old = before[path]
            if old is None:
                path.unlink(missing_ok=True)
            else:
                path.write_bytes(old)
        raise
    finally:
        for temporary in staged:
            temporary.unlink(missing_ok=True)
    return len(changed)


def offer_from_text(value):
    fields = value.split(",", 4)
    if len(fields) < 3:
        raise CourseError("--offering 格式：专业,学期,学分[,修读性质[,资料情况]]")
    fields += [""] * (5 - len(fields))
    return dict(zip(("major", "semester", "credits", "requirement", "resources"), fields))


def ask(label, current=None, required=False):
    hint = f" [{current}]" if current else ""
    while True:
        result = input(f"{label}{hint}: ").strip()
        if result or not required:
            return result or (current if current is not None else "")
        print(f"{label}不能为空")


def new_course(args, root, majors):
    interactive = not args.name and not args.category and not args.major and not args.semester and not args.credits
    name = ask("课程名称", required=True) if interactive else (args.name or "")
    category = ask("分类（" + "／".join(CATEGORIES) + "）", required=True) if interactive else scalar(args.category)
    major = ask("专业（" + "／".join([*majors, "通用"]) + "）", required=True) if interactive else scalar(args.major)
    semester = ask("学期（如大二上）", required=True) if interactive else scalar(args.semester)
    credits = ask("学分", required=True) if interactive else scalar(args.credits)
    if not all((name, category, major, semester, credits)):
        raise CourseError("缺少必填参数：--name、--category、--major、--semester、--credits")
    check_name(name)
    if category not in CATEGORIES:
        raise CourseError(f"无效分类：{category}；可选 {'、'.join(CATEGORIES)}")
    offerings = [{"major": major, "semester": semester, "credits": credits,
                  "requirement": scalar(args.requirement), "resources": scalar(args.resources)}]
    offerings.extend(offer_from_text(value) for value in args.offering)
    if interactive:
        offerings[0]["requirement"] = ask("修读性质（可留空）")
        offerings[0]["resources"] = ask("资料情况（可留空）")
        while ask("继续添加专业／学期组合？输入 y 继续") .lower() in ("y", "yes"):
            offerings.append({"major": ask("专业", required=True), "semester": ask("学期", required=True),
                              "credits": ask("学分", required=True), "requirement": ask("修读性质（可留空）"),
                              "resources": ask("资料情况（可留空）")})
    for offering in offerings:
        validate_offering(offering, name, majors, legacy=False)
    pairs = [(o["major"], o["semester"]) for o in offerings]
    if len(pairs) != len(set(pairs)):
        raise CourseError("同一门课程不能重复添加相同专业＋学期 offering")
    path = root / "docs" / "课程" / (name + ".md")
    for existing in path.parent.glob("*.md"):
        if name_key(existing.stem) == name_key(name):
            raise CourseError(f"课程已存在（大小写等价）：{existing}")
    body = f"\n# {name}\n\n## 课程介绍\n\n<!-- 请填写课程内容、学习建议等。 -->\n\n## 授课教师\n\n<!-- 请填写教师姓名、授课方式和客观说明；没有资料时留空。 -->\n\n## 课程资料\n\n<!-- 请填写资料链接，附件请放在 docs/assets/courses/{name}/。 -->\n"
    content = to_markdown({"title": name, "category": category, "offerings": offerings}, body)
    return {path: content}, path


def edit_course(args, root, majors):
    name = scalar(args.name) or ask("课程名称", required=True)
    path = root / "docs" / "课程" / (name + ".md")
    if not path.exists():
        raise CourseError(f"课程不存在：{path}；本命令不负责课程改名")
    data, body = read_metadata(path.read_text(encoding="utf-8"), path)
    offerings = data["offerings"]
    interactive = not any((args.major, args.semester, args.add, args.remove, args.set_major,
                           args.set_semester, args.credits is not None, args.requirement is not None,
                           args.resources is not None))
    if interactive:
        print("当前 offering：")
        for i, item in enumerate(offerings, 1):
            print(f"{i}. {item['major']}／{item['semester']}／{scalar(item.get('credits'))} 学分／{scalar(item.get('requirement'))}")
        operation = ask("操作（增加／修改／移除）", required=True)
        if operation not in ("增加", "修改", "移除"):
            raise CourseError("操作必须是 增加、修改或移除")
        if operation == "增加":
            args.add = True
            args.major = ask("专业", required=True)
            args.semester = ask("学期", required=True)
            args.credits = ask("学分", required=True)
            args.requirement = ask("修读性质（可留空）")
            args.resources = ask("资料情况（可留空）")
        else:
            try:
                target = offerings[int(ask("选择编号", required=True)) - 1]
            except (ValueError, IndexError):
                raise CourseError("无效 offering 编号") from None
            args.major, args.semester = target["major"], target["semester"]
            if operation == "移除":
                args.remove = True
            else:
                args.set_major = ask("新的专业", target["major"])
                args.set_semester = ask("新的学期", target["semester"])
                args.credits = ask("新的学分", scalar(target.get("credits")))
                args.requirement = ask("新的修读性质（留空保持当前）", scalar(target.get("requirement")))
                args.resources = ask("新的资料情况（留空保持当前）", scalar(target.get("resources")))
    if args.add:
        if not all((args.major, args.semester, args.credits)):
            raise CourseError("新增 offering 需要 --major、--semester、--credits")
        item = {"major": args.major, "semester": args.semester, "credits": args.credits,
                "requirement": scalar(args.requirement), "resources": scalar(args.resources)}
        validate_offering(item, path, majors, legacy=False)
        offerings.append(item)
    else:
        if not args.major or not args.semester:
            raise CourseError("修改或移除时需指定 --major 和 --semester 以唯一定位 offering")
        matches = [o for o in offerings if o["major"] == args.major and o["semester"] == args.semester]
        if len(matches) != 1:
            raise CourseError(f"找不到唯一 offering：{args.major}／{args.semester}")
        item = matches[0]
        if args.remove:
            if len(offerings) == 1:
                raise CourseError("不能移除唯一 offering；课程正文需至少关联一个专业／学期")
            offerings.remove(item)
        else:
            for key, value in (("major", args.set_major), ("semester", args.set_semester),
                               ("credits", args.credits), ("requirement", args.requirement),
                               ("resources", args.resources)):
                if value is not None:
                    item[key] = scalar(value)
            validate_offering(item, path, majors)
    pairs = [(o["major"], o["semester"]) for o in offerings]
    if len(pairs) != len(set(pairs)):
        raise CourseError("修改后出现重复专业＋学期 offering")
    return {path: to_markdown(data, body)}, path


def main():
    if len(sys.argv) < 2:
        raise CourseError("请通过 npm run new:course / edit:course / generate / build / preview 执行")
    action = sys.argv[1]
    parser = argparse.ArgumentParser(prog=f"npm run {action}:course" if action in ("new", "edit") else f"npm run {action}")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1], help="仓库根目录，供临时环境测试")
    if action == "new":
        for field in ("name", "category", "major", "semester", "credits", "requirement", "resources"):
            parser.add_argument("--" + field)
        parser.add_argument("--offering", action="append", default=[], help="额外 offering：专业,学期,学分[,修读性质[,资料情况]]")
    elif action == "edit":
        for field in ("name", "major", "semester", "set-major", "set-semester", "credits", "requirement", "resources"):
            parser.add_argument("--" + field)
        parser.add_argument("--add", action="store_true")
        parser.add_argument("--remove", action="store_true")
    elif action not in ("generate", "build", "preview"):
        raise CourseError(f"未知命令：{action}")
    args = parser.parse_args(sys.argv[2:])
    root = args.root.resolve()
    config_path = root / "config" / "course-majors.json"
    majors = json.loads(config_path.read_text(encoding="utf-8"))
    source_change = {}
    if action == "new":
        source_change, source_path = new_course(args, root, majors)
    elif action == "edit":
        source_change, source_path = edit_course(args, root, majors)
    courses, warnings = load_courses(root, majors, source_change)
    changes = generate_changes(root, courses, majors)
    changes.update(source_change)
    validate_links(changes, root)
    count = write_changes(changes)
    for warning in warnings:
        print("警告：" + warning, file=sys.stderr)
    print(f"已更新 {count} 个文件；课程数 {len(courses)}。")
    if action in ("new", "edit"):
        print(f"课程文件：{source_path}")
    if action in ("build", "preview"):
        command = [sys.executable, "-m", "mkdocs", "build", "--strict"] if action == "build" else [sys.executable, "-m", "mkdocs", "serve"]
        try:
            result = subprocess.run(command, cwd=root, check=False)
        except ModuleNotFoundError:
            raise CourseError("缺少 MkDocs；请先运行 npm run setup") from None
        if result.returncode:
            raise CourseError(f"MkDocs {action} 失败（退出码 {result.returncode}）")


if __name__ == "__main__":
    try:
        main()
    except (CourseError, OSError, KeyboardInterrupt) as exc:
        print(f"错误：{exc}", file=sys.stderr)
        raise SystemExit(1) from None
