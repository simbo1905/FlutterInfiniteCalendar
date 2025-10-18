import fs from 'node:fs';
import path from 'node:path';
import { getEnv, getBoolEnv, getIntEnv, requireEnv } from './env.js';

function parseJsonFile(filePath) {
  const resolved = path.isAbsolute(filePath)
    ? filePath
    : path.resolve(process.cwd(), filePath);
  if (!fs.existsSync(resolved)) {
    throw new Error(`Capability profile file not found: ${resolved}`);
  }
  return JSON.parse(fs.readFileSync(resolved, 'utf8'));
}

function parseJsonString(json) {
  try {
    return JSON.parse(json);
  } catch (error) {
    throw new Error(`Unable to parse APPIUM_CAPS_JSON. ${error.message}`);
  }
}

function resolveCapabilities() {
  const profilePath = getEnv('APPIUM_CAPS_PATH');
  const rawJson = getEnv('APPIUM_CAPS_JSON');

  if (profilePath) {
    return parseJsonFile(profilePath);
  }
  if (rawJson) {
    return parseJsonString(rawJson);
  }

  const automationName = getEnv('APPIUM_AUTOMATION_NAME', 'FlutterIntegration');
  const platformName = requireEnv('APPIUM_PLATFORM_NAME');
  const deviceName = requireEnv('APPIUM_DEVICE_NAME');
  const app = requireEnv('APPIUM_APP');

  const capabilities = {
    platformName,
    'appium:deviceName': deviceName,
    'appium:automationName': automationName,
    'appium:app': app,
    'appium:noReset': getBoolEnv('APPIUM_NO_RESET', true),
    'appium:newCommandTimeout': getIntEnv('APPIUM_NEW_COMMAND_TIMEOUT', 300)
  };

  const optionalKeys = {
    'appium:platformVersion': getEnv('APPIUM_PLATFORM_VERSION'),
    'appium:udid': getEnv('APPIUM_UDID'),
    'appium:orientation': getEnv('APPIUM_ORIENTATION'),
    'appium:flutterServerLaunchTimeout': getIntEnv('APPIUM_FLUTTER_SERVER_LAUNCH_TIMEOUT'),
    'appium:flutterSystemPort': getIntEnv('APPIUM_FLUTTER_SYSTEM_PORT'),
    'appium:autoAcceptAlerts': getBoolEnv('APPIUM_AUTO_ACCEPT_ALERTS')
  };

  for (const [key, value] of Object.entries(optionalKeys)) {
    if (value !== undefined) {
      capabilities[key] = value;
    }
  }

  const extraCapsPath = getEnv('APPIUM_EXTRA_CAPS_PATH');
  if (extraCapsPath) {
    Object.assign(capabilities, parseJsonFile(extraCapsPath));
  }

  const extraCapsJson = getEnv('APPIUM_EXTRA_CAPS_JSON');
  if (extraCapsJson) {
    Object.assign(capabilities, parseJsonString(extraCapsJson));
  }

  return { capabilities };
}

export function buildSessionConfig() {
  const baseConfig = resolveCapabilities();
  const hostname = getEnv('APPIUM_HOST', '127.0.0.1');
  const port = getIntEnv('APPIUM_PORT', 4723);
  const pathValue = getEnv('APPIUM_PATH', '/');
  const protocol = getEnv('APPIUM_PROTOCOL', 'http');

  const config = {
    hostname,
    port,
    path: pathValue,
    protocol,
    logLevel: getEnv('APPIUM_LOG_LEVEL', 'info'),
    connectionRetryCount: getIntEnv('APPIUM_CONNECTION_RETRY_COUNT', 3),
    connectionRetryTimeout: getIntEnv('APPIUM_CONNECTION_RETRY_TIMEOUT', 60000),
    capabilities: baseConfig.capabilities ?? baseConfig
  };

  return config;
}
