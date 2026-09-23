import { mkdirSync, copyFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const dist = join(root, 'dist');

mkdirSync(dist, { recursive: true });
copyFileSync(join(root, 'src', 'index.js'), join(dist, 'index.js'));
copyFileSync(join(root, 'src', 'math.js'), join(dist, 'math.js'));

const info = {
  name: 'gaffer-ci-github-actions',
  entry: 'dist/index.js',
};
writeFileSync(join(dist, 'build-info.json'), `${JSON.stringify(info, null, 2)}\n`);

console.log('built dist/index.js, dist/math.js, dist/build-info.json');
