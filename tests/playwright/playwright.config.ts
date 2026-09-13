import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    baseURL: process.env.INTEGRATION_URL ?? 'http://clue.localhost',
  },
});
