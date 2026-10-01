# 贡献指南

本网站欢迎一切贡献 🎉  

如果你想要为本网站进行贡献，以下是一些指南。

## 本地构建
1. 克隆本项目 repo
    ```shell
    $ git clone https://github.com/NBUComputerRepairClub/nbu-icicles.git
    $ cd nbu-icicles
    ```
2. 准备 Python 依赖（MkDocs 及其插件；首次运行一次）
    ```shell
    $ npm run setup
    ```

3. 生成索引并启动本地服务
    ```shell
    $ npm run preview
    ```
    提交前运行严格构建：
    ```shell
    $ npm run build
    ```
    - 浏览器访问 http://127.0.0.1:8000/ 。`build` 不会暗中联网安装依赖；缺环境时先运行 `npm run setup`。

### 新增或调整课程

新增课程运行 `npm run new:course`，依次填写课程名称、分类、专业、学期和学分；可以继续添加多个专业／学期组合。修读性质与资料情况可留空，不确定时不要猜测。命令创建 `docs/课程/课程名.md`，并立即更新总览、分类页、专业速查及导航；已有同名文件绝不会覆盖。

非交互示例：

```shell
npm run new:course -- --name "示例课程" --category "专业课程" --major EI --semester 大二上 --credits 2 --requirement 选修
```

新建时可重复传入 `--offering "ECE,大二下,3,必修"`。已有课程通过 `edit:course` 修改，常见用法如下。修读性质属于每条专业＋学期关系，可以保留“网络方向必修”等具体表述。

#### 常用修改命令速查

以下以“示例课程”为例，命令彼此独立；请把课程名、专业和学期换成**当前实际值**。其中 `--major` 与 `--semester` 用来定位要修改的旧记录，`--set-major` 与 `--set-semester` 才是修改后的新值。

```powershell
# 交互式选择已有课程的 offering 并修改
npm run edit:course -- --name "示例课程"

# 修改 EI 大二上这条记录的学分、修读性质或资料情况
npm run edit:course -- --name "示例课程" --major EI --semester 大二上 --credits 2.5
npm run edit:course -- --name "示例课程" --major EI --semester 大二上 --requirement "选修"
npm run edit:course -- --name "示例课程" --major EI --semester 大二上 --resources "已有笔记"

# 把这条记录改到大二下，或改为 ECE 专业
npm run edit:course -- --name "示例课程" --major EI --semester 大二上 --set-semester 大二下
npm run edit:course -- --name "示例课程" --major EI --semester 大二上 --set-major ECE

# 增加或移除另一条专业＋学期记录
npm run edit:course -- --name "示例课程" --add --major ECE --semester 大二下 --credits 3 --requirement "必修"
npm run edit:course -- --name "示例课程" --remove --major ECE --semester 大二下
```

每次 `edit:course` 成功后都会自动刷新索引与导航。改过专业或学期后，下一次定位时应使用新值；不能移除课程的最后一条 offering。本命令不负责课程改名或修改分类：课程介绍、教师说明及资料链接直接编辑对应的 `docs/课程/课程名.md`；手工改动分类或其他 front matter 后运行 `npm run generate`。

```powershell
# 常用检查与预览
npm run generate       # 根据 front matter 重新生成课程表和导航
npm run preview        # 本地预览：http://127.0.0.1:8000/
npm run build          # 生成、校验并严格构建；提交前运行
npm test               # 运行课程维护命令的集成测试
git status             # 查看哪些文件被修改
git diff --check       # 检查空白字符错误
```

课程正文中的**课程介绍、授课教师说明和资料链接**仍需贡献者自己填写，工具不会编造评价。附件放在 `docs/assets/courses/课程名/`，正文使用相对链接。不要修改有生成标记的表格；提交时把生成页面及 `mkdocs.yml` 一并提交。

专业—学院映射位于 `config/course-majors.json`。历史课程的 `未标注／未注明` 会警告并进入“信息待补全”，新建时不能使用这些占位值。争议历史数据见 `COURSE_MIGRATION_REVIEW.md`，请核实后通过 `edit:course` 填写。

## 贡献内容
### 网站结构
课程正文按课程名称集中存放；专业与学期概览只负责索引，课程介绍、授课教师和资料链接写在同一份课程页面中。

在源代码层面，每门课程对应 `docs/课程/课程名.md`，不再为每门课程创建文件夹或 `index.md`。YAML front matter 记录 `title`、`category`、`offerings`；每条 offering 包含专业 `major`、学期 `semester`、学分 `credits`，可选修读性质 `requirement` 和资料情况 `resources`。不分专业写 `major: 通用`；旧资料无法确定时保留 `未标注／未注明`，但新增时必须填明确值。PDF、DOC、ZIP、图片等附件统一放在 `docs/assets/courses/课程名/`。课程导航和概览由 `npm run generate` 更新，不再手改课程路径。

```text
.
├── docs
│   ├── contributing.md     # 本页
│   ├── template.md         # 课程页面模板
│   ├── index.md            # 主页
│   ├── css/                # 本站用到的所有 css 样式
│   ├── images/             # 仅用来保存网站图标
│   ├── js/                 # 本站用到的所有 js 脚本
│   ├── 课程/                # 一个课程一份「课程名.md」
│   ├── assets/courses/      # 课程附件
│   ├── 本科生课程/          # 本科生概览与课程分类页面
│   ├── 学院汇总/            # 按学院归档专业速查页（CS.md、ECE.md、EI.md、EE.md）
│   ├── ....
├── mkdocs.yml          # mkdocs 站点设置
├── overrides/          # mkdocs-material 个性主题设置
└── requirements.txt    # 本站构建所需全部 python 依赖
```

### 贡献守则
你可以对本网站进行任何贡献，包括完善、更新页面内容，添加新页面，样式修改等等。

如果添加非课程页面，请更新 `mkdocs.yml` 中对应的非课程导航；课程导航由生成器自动维护。

对于页面内容：

- 对于课程请进行客观的评价，尽量不要带有主观色彩（比较主观的内容可以在页面下评论）
- 对于外部资源，请尽量插入链接，不要将文件传入本 repo
- 尽量不要上传有版权的文件，例如课件等
- 对于自己的笔记、复习提纲等材料：
    - 如果有自己的网站，推荐放在自己的网站并在此插入链接
    - 也可以把适合入库的附件放在 `docs/assets/courses/课程名/`，并从课程页使用相对链接，例如 `../assets/courses/数值计算/main.pdf`
- 尽量规范编写 markdown，避免出现格式错误
    - 如果你实在搞不定，不要担心，尽管上传，我们发现后会及时进行修改

!!! note
    针对还完全没有内容的空页面，我们提供了一个[模板](./template.md)，可以在模板的[源码](https://github.com/NBUComputerRepairClub/nbu-icicles/blob/main/docs/template.md?plain=1)基础上修改使用。

### 贡献方式
#### Pull Request（推荐）
推荐通过 PR（即 Pull Request）的形式来进行贡献，具体流程：

- 在 GitHub 网页端点击右上角的 fork，将本仓库 fork 到自己的账号下
- 在自己账号的对应仓库中进行修改
- 修改完成后，点击 New pull request，提交一个 PR
- 等待其他人审核、修改，然后合并到本 repo 中

#### 直接提交
对于在 Organization 中的同学，如果实在觉得 PR 过程有些复杂，也可以直接修改、提交到本仓库中（可以在线修改，也可以 clone 到本地修改然后 commit、push）。如果在提交中存在问题，我们后续会及时进行修改。（不过还是不推荐这种方式）

!!! note
    可以直接通过网站顶部的页面标题右侧的编辑按钮 :material-pencil: 定位到对应的 GitHub 页面进行修改。

![](./assets/img/2024-08-22-15-48-12.png)
![alt text](assets/img/contributing2.png)
![alt text](assets/img/contributing3.png)
最后点击commit changes 就修改成功啦
## 问题反馈
如果你发现本网站内容存在问题，请优先在对应页面下方评论区中进行评论，或者在 repo 中开一个 issue 来提出问题。

如果你发现本网站存在侵犯您权益的内容，请通过 issue 联系我们，我们会进行删除。
