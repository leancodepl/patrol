import { defineConfig } from "@playwright/test";

const outputDir = process.env.PATROL_TEST_RESULTS_DIR || "./test-results";
const outputFolder =
  process.env.PATROL_TEST_REPORT_DIR || "./playwright-report";
const baseURL = process.env.BASE_URL;
const headless = process.env.HEADLESS === "true";
const parallel = process.env.PARALLEL === "true";
const video = process.env.VIDEO === "true";

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL,
    headless,
    video: video ? 'retain-on-failure' : 'off',
  },
  workers: process.env.PARALLEL ? 4 : undefined,
  fullyParallel: parallel,
  globalSetup: require.resolve("./tests/setup"),
  // Output test results to the tested app directory
  outputDir,
  reporter: [["html", { outputFolder, open: "never" }], ["json"], ["list"]],
  timeout: 600000,
});
