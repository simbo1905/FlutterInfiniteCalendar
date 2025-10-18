import { remote } from 'webdriverio';
import { buildSessionConfig } from './capabilities.js';

let driver;

export async function ensureDriver() {
  if (!driver) {
    const config = buildSessionConfig();
    driver = await remote(config);
  }
  return driver;
}

export async function shutdownDriver() {
  if (driver) {
    try {
      await driver.deleteSession();
    } catch (error) {
      console.warn('Failed to delete Appium session cleanly:', error.message);
    } finally {
      driver = undefined;
    }
  }
}
