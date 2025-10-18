import { expect } from 'chai';
import { ensureDriver } from './helpers/session.js';
import { findAllByType, findByText } from './helpers/flutter.js';
import { artifactPath, writeJsonArtifact } from './helpers/artifacts.js';

describe('Milestone 1 - Smoke Connectivity', function () {
  this.timeout(600000);

  let driver;

  before(async () => {
    driver = await ensureDriver();
  });

  it('connects to the app and counts visible meal cards', async () => {
    await findByText(driver, 'Meal Planner', { timeout: 45000 });
    const cards = await findAllByType(driver, 'MealCard', { timeout: 30000 });

    const screenshotFile = artifactPath('m1', 'initial-dashboard.png');
    await driver.saveScreenshot(screenshotFile);

    writeJsonArtifact('m1/summary.json', {
      timestamp: new Date().toISOString(),
      mealCardCount: cards.length
    });

    expect(cards.length).to.be.greaterThan(0);
  });
});
