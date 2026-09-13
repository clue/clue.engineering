import { test, expect } from '@playwright/test';

test('dismisses the contact overlay without reloading', async ({ page }) => {
  // not submitted, a valid submission would send a real mail
  await page.goto('/contact#thanks');
  await expect(page.locator('#thanks')).toBeVisible();

  // marker survives an intercepted click, but not a real navigation
  await page.evaluate(() => { (window as any).__mark = 'alive'; });
  await page.locator('#thanks a[href="contact"]').click();

  await expect(page.locator('#thanks')).toBeHidden();
  expect(await page.evaluate(() => (window as any).__mark)).toBe('alive');
});

test('hides the contact form honeypot', async ({ page }) => {
  await page.goto('/contact');

  // `contact.php` silently discards any submission filling this in
  await expect(page.locator('#url')).toBeHidden();
});
