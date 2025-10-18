import fs from 'node:fs';
import path from 'node:path';
import { getEnv } from './env.js';

const rootDir = path.resolve(process.cwd());
const artifactDir = path.isAbsolute(getEnv('APPIUM_ARTIFACT_DIR', 'artifacts'))
  ? getEnv('APPIUM_ARTIFACT_DIR', 'artifacts')
  : path.resolve(rootDir, getEnv('APPIUM_ARTIFACT_DIR', 'artifacts'));

export function ensureArtifactDir() {
  fs.mkdirSync(artifactDir, { recursive: true });
  return artifactDir;
}

export function artifactPath(...segments) {
  ensureArtifactDir();
  return path.join(artifactDir, ...segments);
}

export function writeJsonArtifact(fileName, data) {
  const target = artifactPath(fileName);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, JSON.stringify(data, null, 2));
  return target;
}
