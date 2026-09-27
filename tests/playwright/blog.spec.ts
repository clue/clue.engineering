import { test, expect } from '@playwright/test';
import { collectErrors, stubAnalytics } from './helpers';

test('generates the blog post list', async ({ page }) => {
  await page.goto('/blog');

  await expect(page.locator('#posts article')).not.toHaveCount(0);
});

test('loads a blog post without errors', async ({ page }) => {
  await page.goto('/blog');
  const post = await page.locator('#posts article h4 a').first().getAttribute('href');

  const errors = collectErrors(page);
  await stubAnalytics(page);

  await page.goto(post!);

  expect(errors).toEqual([]);

  // post pages are the only ones resolving nav links through a `../` prefix
  await page.locator('header nav a[href$="blog"]').click();
  await expect(page).toHaveURL('/blog');
});

test('filters the blog list by tag and restores it without reloading', async ({ page }) => {
  await page.goto('/blog');
  const all = await page.locator('#posts article').count();
  const tag = await page.locator('.tag-anchor').first().getAttribute('id');

  await page.goto(`/blog#${tag}`);
  const tagged = await page.locator('#posts article:visible').count();
  expect(tagged).toBeGreaterThan(0);
  expect(tagged).toBeLessThan(all);

  await page.evaluate(() => { (window as any).__mark = 'alive'; });
  await page.locator(`.tagged-${tag} a[href="blog"]`).first().click();

  await expect(page.locator('#posts article:visible')).toHaveCount(all);
  expect(await page.evaluate(() => (window as any).__mark)).toBe('alive');
});
