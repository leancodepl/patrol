import { defineConfig } from "@playwright/test"

export default defineConfig({
  testDir: "./tests/__tests__",
  testMatch: /^(?!.*\.integration\.).*\.test\.ts$/,
  reporter: "list",
  timeout: 10_000,
  workers: 1,
})
