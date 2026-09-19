const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repo = path.resolve(__dirname, '..');

function run(script, root, args = []) {
  const action = ({ 'new:course': 'new', 'edit:course': 'edit' })[script] || script;
  const result = spawnSync(process.execPath, [path.join(repo, 'scripts', 'courses.cjs'), action, '--root', root, ...args], {
    cwd: repo, encoding: 'utf8', env: process.env,
  });
  assert.equal(result.status, 0, `${script} failed:\n${result.stdout}\n${result.stderr}`);
  return result;
}

function fail(script, root, args) {
  const action = ({ 'new:course': 'new', 'edit:course': 'edit' })[script] || script;
  const result = spawnSync(process.execPath, [path.join(repo, 'scripts', 'courses.cjs'), action, '--root', root, ...args], {
    cwd: repo, encoding: 'utf8', env: process.env,
  });
  assert.notEqual(result.status, 0, `${script} unexpectedly succeeded`);
  return result.stderr;
}

function fixture(callback) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'icicles-course-'));
  try {
    fs.cpSync(path.join(repo, 'docs'), path.join(root, 'docs'), { recursive: true });
    fs.cpSync(path.join(repo, 'overrides'), path.join(root, 'overrides'), { recursive: true });
    fs.cpSync(path.join(repo, 'config'), path.join(root, 'config'), { recursive: true });
    fs.copyFileSync(path.join(repo, 'mkdocs.yml'), path.join(root, 'mkdocs.yml'));
    return callback(root);
  } finally {
    const resolved = fs.realpathSync(root);
    const tempRoot = fs.realpathSync(os.tmpdir()) + path.sep;
    assert.ok(resolved.startsWith(tempRoot) && path.basename(resolved).startsWith('icicles-course-'));
    fs.rmSync(resolved, { recursive: true, force: true });
  }
}

test('new course appears in its subject and semester index', () => {
  fixture((root) => {
    run('new:course', root, ['--name', '临时测试课程', '--category', '专业课程',
      '--major', 'CS', '--semester', '大二上', '--credits', '2']);
    assert.ok(fs.existsSync(path.join(root, 'docs', '课程', '临时测试课程.md')));
    assert.match(fs.readFileSync(path.join(root, 'docs', '学院汇总', '人工智能学院', 'CS.md'), 'utf8'), /临时测试课程/);
    const mappingPath = path.join(root, 'config', 'course-majors.json');
    const mapping = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
    mapping.BIO = { name: '生物信息学', college: '新学院' };
    fs.writeFileSync(mappingPath, JSON.stringify(mapping), 'utf8');
    run('new:course', root, ['--name', '临时新增专业课程', '--category', '专业课程',
      '--major', 'BIO', '--semester', '大一上', '--credits', '2']);
    assert.match(fs.readFileSync(path.join(root, 'docs', '学院汇总', '新学院', 'BIO.md'), 'utf8'), /临时新增专业课程/);
  });
});

test('one body supports different requirements across majors and strict build', () => {
  fixture((root) => {
    const sample = '临时跨专业课程';
    run('new:course', root, ['--name', sample, '--category', '专业课程',
      '--major', 'EI', '--semester', '大二上', '--credits', '2', '--requirement', '选修']);
    run('edit:course', root, ['--name', sample, '--add', '--major', 'ECE',
      '--semester', '大二下', '--credits', '3', '--requirement', '必修']);
    const read = (file) => fs.readFileSync(path.join(root, file), 'utf8');
    assert.match(read('docs/学院汇总/集成电路学院/EI.md'), /临时跨专业课程[^\n]*\|选修\|/);
    assert.match(read('docs/学院汇总/人工智能学院/ECE.md'), /临时跨专业课程[^\n]*\|必修\|/);
    assert.match(read('docs/本科生课程/专业课程/index.md'), /ECE：必修；EI：选修/);
    assert.match(read('docs/本科生课程/index.md'), /临时跨专业课程/);
    assert.match(read('mkdocs.yml'), /临时跨专业课程/);
    run('build', root);
    const once = read('docs/本科生课程/index.md') + read('mkdocs.yml');
    run('generate', root);
    run('generate', root);
    assert.equal(read('docs/本科生课程/index.md') + read('mkdocs.yml'), once);
    const body = read(`docs/课程/${sample}.md`).split('---\n').slice(2).join('---\n');
    run('edit:course', root, ['--name', sample, '--major', 'ECE', '--semester', '大二下',
      '--requirement', '网络方向必修']);
    assert.match(read('docs/学院汇总/人工智能学院/ECE.md'), /临时跨专业课程[^\n]*网络方向必修/);
    assert.match(read('docs/学院汇总/集成电路学院/EI.md'), /临时跨专业课程[^\n]*选修/);
    run('edit:course', root, ['--name', sample, '--major', 'ECE', '--semester', '大二下', '--remove']);
    assert.ok(!read('docs/学院汇总/人工智能学院/ECE.md').includes(sample));
    assert.ok(read('docs/学院汇总/集成电路学院/EI.md').includes(sample));
    assert.equal(read(`docs/课程/${sample}.md`).split('---\n').slice(2).join('---\n'), body);
  });
});

test('invalid and duplicate course requests leave no partial changes', () => {
  fixture((root) => {
    const coursePath = path.join(root, 'docs', '课程', '无效测试.md');
    const navPath = path.join(root, 'mkdocs.yml');
    const before = fs.readFileSync(navPath, 'utf8');
    assert.match(fail('new:course', root, ['--name', '无效测试', '--category', '专业课程',
      '--major', 'EI', '--semester', '未注明', '--credits', '2']), /未注明/);
    assert.ok(!fs.existsSync(coursePath));
    assert.equal(fs.readFileSync(navPath, 'utf8'), before);
    assert.match(fail('new:course', root, ['--name', '数据库', '--category', '专业课程',
      '--major', 'CS', '--semester', '大三上', '--credits', '2']), /已存在/);
    assert.match(fail('new:course', root, ['--name', '无效测试', '--category', '专业课程',
      '--major', 'EI', '--semester', '大二上', '--credits', '2',
      '--offering', 'EI,大二上,2']), /重复/);
    assert.match(fail('new:course', root, ['--name', 'it项目管理', '--category', '专业课程',
      '--major', 'CS', '--semester', '大三上', '--credits', '2']), /已存在/);
    assert.ok(!fs.existsSync(coursePath));
    fs.appendFileSync(path.join(root, 'docs', '课程', '数据库.md'), '\n[不存在的资料](缺失附件.pdf)\n');
    assert.match(fail('generate', root, []), /无效站内链接/);
    assert.equal(fs.readFileSync(navPath, 'utf8'), before);
  });
});
