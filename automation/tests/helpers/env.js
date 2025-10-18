import path from 'node:path';
import fs from 'node:fs';
import dotenv from 'dotenv';

const defaultEnvPath = path.resolve(process.cwd(), '.env');
const envFile = process.env.APPIUM_ENV
  ? resolveEnvPath(process.env.APPIUM_ENV)
  : defaultEnvPath;

if (fs.existsSync(envFile)) {
  dotenv.config({ path: envFile });
}

function resolveEnvPath(input) {
  if (path.isAbsolute(input)) {
    return input;
  }
  return path.resolve(process.cwd(), input);
}

export function getEnv(key, fallback) {
  const value = process.env[key];
  if (value === undefined || value === '') {
    return fallback;
  }
  return value;
}

export function requireEnv(key) {
  const value = getEnv(key);
  if (value === undefined) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export function getBoolEnv(key, fallback = false) {
  const value = getEnv(key);
  if (value === undefined) {
    return fallback;
  }
  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
}

export function getIntEnv(key, fallback) {
  const value = getEnv(key);
  if (value === undefined) {
    return fallback;
  }
  const parsed = Number.parseInt(value, 10);
  if (Number.isNaN(parsed)) {
    throw new Error(`Environment variable ${key} must be an integer. Received: ${value}`);
  }
  return parsed;
}
