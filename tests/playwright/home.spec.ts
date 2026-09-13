import { test, expect } from '@playwright/test';

test('applies the generated stylesheets', async ({ page }) => {
  await page.goto('/');

  // an empty Tailwind build still serves a 200, so check a class resolved
  const background = await page.locator('body > header').evaluate(
    el => getComputedStyle(el).backgroundColor,
  );

  expect(background).not.toBe('rgba(0, 0, 0, 0)');
});

test('fits the viewport on a phone', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 812 });
  await page.goto('/');

  const overflows = await page.evaluate(
    () => document.documentElement.scrollWidth > window.innerWidth,
  );
  expect(overflows).toBe(false);
});
