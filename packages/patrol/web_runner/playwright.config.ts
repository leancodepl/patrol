import { defineConfig, VideoMode } from "@playwright/test"
import { writeFileSync } from "fs"

const outputDir = process.env.PATROL_TEST_RESULTS_DIR || "./test-results"
const baseURL = process.env.BASE_URL

const retries = process.env.PLAYWRIGHT_RETRIES ? parseInt(process.env.PLAYWRIGHT_RETRIES) : undefined
const video = process.env.PLAYWRIGHT_VIDEO ? (process.env.PLAYWRIGHT_VIDEO as VideoMode) : undefined
const timeout = process.env.PLAYWRIGHT_TIMEOUT ? parseInt(process.env.PLAYWRIGHT_TIMEOUT) : 300000
const workers = process.env.PLAYWRIGHT_WORKERS ? parseInt(process.env.PLAYWRIGHT_WORKERS) : 1
const reporter = process.env.PLAYWRIGHT_REPORTER ? JSON.parse(process.env.PLAYWRIGHT_REPORTER) : undefined

writeFileSync(
  "log.txt",
  `const retries = ${retries}; const video = ${video}; const timeout = ${timeout}; const workers = ${workers}; const reporter = ${reporter}`,
)

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL,
    headless: false,
    video,
  },
  globalSetup: require.resolve("./tests/setup"),
  // Output test results to the tested app directory
  outputDir,
  reporter: reporter,
  retries,
  timeout: timeout ?? 300000,
  workers,
})
