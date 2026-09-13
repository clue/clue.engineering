import { Page } from '@playwright/test';

// stubbed rather than blocked, a blocked request logs a console error without URL
const thirdParty = /plausible\.io/;

export function collectErrors(page: Page): string[] {
  const errors: string[] = [];
  page.on('pageerror', err => errors.push(`pageerror: ${err.message}`));
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(`console: ${msg.text()}`);
  });
  page.on('requestfailed', req => errors.push(`failed: ${req.url()}`));
  page.on('response', res => {
    if (res.status() >= 400) errors.push(`${res.status()}: ${res.url()}`);
  });
  return errors;
}

export async function stubAnalytics(page: Page): Promise<void> {
  await page.route(thirdParty, route => route.fulfill({
    status: 200,
    contentType: 'application/javascript',
    body: '',
  }));
}
