import { ELEMENT_KEY } from 'webdriver';

const W3C_ELEMENT_KEY = ELEMENT_KEY;

export function getElementId(element) {
  if (!element) {
    return undefined;
  }
  if (typeof element === 'string') {
    return element;
  }
  return element.elementId || element[ELEMENT_KEY] || element[W3C_ELEMENT_KEY];
}

async function retry(fn, { timeout = 10000, interval = 250, message } = {}) {
  const started = Date.now();
  let lastError;
  while (Date.now() - started < timeout) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, interval));
    }
  }
  throw new Error(message ?? lastError?.message ?? 'Operation timed out');
}

export async function findByKey(driver, key, options = {}) {
  return retry(
    () => driver.findElement('key', key),
    { ...options, message: `Unable to locate element with key "${key}"` }
  );
}

export async function findAllByType(driver, type, options = {}) {
  return retry(
    () => driver.findElements('type', type),
    { ...options, message: `No elements found for type "${type}"` }
  );
}

export async function findByText(driver, text, options = {}) {
  return retry(
    () => driver.findElement('text', text),
    { ...options, message: `Unable to locate element with text "${text}"` }
  );
}

export async function getText(driver, element) {
  const id = getElementId(element);
  if (!id) {
    throw new Error('getText was called without a valid element reference.');
  }
  return driver.getElementText(id);
}

export async function tap(driver, element) {
  const id = getElementId(element);
  if (!id) {
    throw new Error('tap was called without a valid element reference.');
  }
  await driver.elementClick(id);
}

export async function dragAndDrop(driver, source, target) {
  const sourceId = getElementId(source);
  const targetId = getElementId(target);
  if (!sourceId || !targetId) {
    throw new Error('dragAndDrop requires valid source and target element references.');
  }
  await driver.execute('flutter: dragAndDrop', {
    source: { element: sourceId },
    target: { element: targetId }
  });
}

export async function waitForAbsent(driver, locator, options = {}) {
  const timeout = options.timeout ?? 5000;
  const start = Date.now();
  while (Date.now() - start < timeout) {
    try {
      await driver.findElement(locator.strategy, locator.selector);
    } catch {
      return true;
    }
    await new Promise((resolve) => setTimeout(resolve, 200));
  }
  throw new Error(
    `Element with ${locator.strategy}=${locator.selector} still present after ${timeout}ms`
  );
}
