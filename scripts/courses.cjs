const { spawnSync } = require('node:child_process');
const path = require('node:path');
const fs = require('node:fs');

const repo = path.resolve(__dirname, '..');
const venv = path.join(repo, '.venv');
const venvPython = path.join(venv, process.platform === 'win32' ? 'Scripts/python.exe' : 'bin/python');
const base = process.platform === 'win32' ? ['py', ['-3']] : ['python3', []];

function invoke(command, args, cwd = repo) {
  const result = spawnSync(command, args, { cwd, stdio: 'inherit', shell: false,
    env: { ...process.env, PYTHONIOENCODING: 'utf-8' } });
  if (result.error) throw result.error;
  process.exit(result.status ?? 1);
}

try {
  const action = process.argv[2];
  if (action === 'setup') {
    if (!fs.existsSync(venvPython)) {
      const result = spawnSync(base[0], [...base[1], '-m', 'venv', venv], { cwd: repo, stdio: 'inherit' });
      if (result.status !== 0) process.exit(result.status ?? 1);
    }
    invoke(venvPython, ['-m', 'pip', 'install', '-r', path.join(repo, 'requirements.txt')]);
  }
  const python = process.env.ICICLES_PYTHON || (fs.existsSync(venvPython) ? venvPython : null);
  if (!python) {
    console.error('缺少 .venv Python 环境。请先运行 npm run setup（不会在 build 时自动联网安装）。');
    process.exit(1);
  }
  invoke(python, [path.join(__dirname, 'courses.py'), action, ...process.argv.slice(3)]);
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
