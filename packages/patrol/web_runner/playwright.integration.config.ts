import { defineConfig } from "@playwright/test"

export default defineConfig({
  testDir: "./tests/__tests__",
  testMatch: "**/*.integration.test.ts",
  reporter: "list",
  timeout: 30_000,
  workers: 1,
  use: {
    headless: true,
  },
})
