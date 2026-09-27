import { test, expect } from '@playwright/test';
import { collectErrors, stubAnalytics } from './helpers';

const templates = ['/', '/blog', '/talks', '/contact', '/support', '/privacy'];

for (const path of templates) {
  test(`loads ${path} without errors`, async ({ page }) => {
    const errors = collectErrors(page);
    await stubAnalytics(page);

    await page.goto(path);

    expect(errors).toEqual([]);
  });
}
