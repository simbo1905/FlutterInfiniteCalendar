import { expect } from 'chai';
import { ensureDriver } from './helpers/session.js';
import {
  findAllByType,
  getElementId,
  getText,
  dragAndDrop
} from './helpers/flutter.js';
import { artifactPath } from './helpers/artifacts.js';

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function getCardsForDay(driver, dayElement) {
  const dayId = getElementId(dayElement);
  if (!dayId) {
    return [];
  }
  try {
    return await driver.findElementsFromElement(dayId, 'type', 'MealCard');
  } catch {
    return [];
  }
}

async function firstTextFromCard(driver, cardElement) {
  const cardId = getElementId(cardElement);
  if (!cardId) {
    return undefined;
  }
  let textNode;
  try {
    textNode = await driver.findElementFromElement(cardId, 'type', 'Text');
  } catch {
    textNode = undefined;
  }
  if (textNode) {
    return await getText(driver, textNode);
  }
  return await getText(driver, cardElement);
}

describe('Milestone 2 - Drag and Drop', function () {
  this.timeout(600000);
  let driver;

  before(async () => {
    driver = await ensureDriver();
    // warm up: ensure day rows loaded
    await findAllByType(driver, 'DayRow', { timeout: 45000 });
  });

  it('reorders meals horizontally within the same day', async () => {
    const dayRows = await findAllByType(driver, 'DayRow', { timeout: 30000 });
    const candidate = [];
    for (const day of dayRows) {
      const cards = await getCardsForDay(driver, day);
      if (cards.length >= 2) {
        candidate.push({ day, cards });
      }
    }
    expect(candidate.length).to.be.greaterThan(
      0,
      'No day found with multiple meal cards to reorder'
    );

    const { day, cards } = candidate[0];
    const initialOrder = await Promise.all(cards.map((card) => firstTextFromCard(driver, card)));

    const beforePath = artifactPath('m2', 'horizontal-before.png');
    await driver.saveScreenshot(beforePath);

    await dragAndDrop(driver, cards[0], cards[1]);
    await delay(1200);

    const refreshedCards = await getCardsForDay(driver, day);
    const newOrder = await Promise.all(
      refreshedCards.map((card) => firstTextFromCard(driver, card))
    );

    const afterPath = artifactPath('m2', 'horizontal-after.png');
    await driver.saveScreenshot(afterPath);

    expect(newOrder[0]).to.equal(
      initialOrder[1],
      'First card should now be the previous second card after horizontal reorder'
    );
  });

  it('moves a meal vertically to a different day', async () => {
    const dayRows = await findAllByType(driver, 'DayRow', { timeout: 30000 });

    let sourceDay;
    let sourceCards;
    let targetDay;

    for (const day of dayRows) {
      const cards = await getCardsForDay(driver, day);
      if (!sourceDay && cards.length > 0) {
        sourceDay = day;
        sourceCards = cards;
        continue;
      }
      if (sourceDay && (!targetDay || cards.length === 0)) {
        targetDay = day;
        if (cards.length === 0) {
          break;
        }
      }
    }

    expect(sourceDay, 'A source day with at least one card is required').to.exist;
    expect(targetDay, 'A destination day to drop the card is required').to.exist;

    const movingCard = sourceCards[0];
    const cardTitle = await firstTextFromCard(driver, movingCard);

    const beforePath = artifactPath('m2', 'vertical-before.png');
    await driver.saveScreenshot(beforePath);

    await dragAndDrop(driver, movingCard, targetDay);
    await delay(1500);

    const sourceRemaining = await getCardsForDay(driver, sourceDay);
    const targetCards = await getCardsForDay(driver, targetDay);

    const afterPath = artifactPath('m2', 'vertical-after.png');
    await driver.saveScreenshot(afterPath);

    const sourceTitles = await Promise.all(
      sourceRemaining.map((card) => firstTextFromCard(driver, card))
    );
    expect(sourceTitles).to.not.include(cardTitle);

    const movedCardTitles = await Promise.all(
      targetCards.map((card) => firstTextFromCard(driver, card))
    );

    expect(movedCardTitles).to.include(cardTitle);
  });
});
