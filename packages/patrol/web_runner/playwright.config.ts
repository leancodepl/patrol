import { defineConfig } from "@playwright/test";

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL: process.env.BASE_URL,
    headless: false,
  },
  globalSetup: require.resolve("./tests/setup"),
  globalTeardown: require.resolve("./tests/teardown"),
  // Output test results to the tested app directory
  outputDir: process.env.PATROL_TEST_RESULTS_DIR || "./test-results",
  reporter: [
    ["html", { 
      outputFolder: process.env.PATROL_TEST_REPORT_DIR || "./playwright-report",
      open: "never"
    }],
    ["list"]
  ],
});
