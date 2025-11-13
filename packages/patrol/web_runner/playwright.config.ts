import { defineConfig, PlaywrightTestOptions, VideoMode } from "@playwright/test"

const outputDir = process.env.PATROL_TEST_RESULTS_DIR || "./test-results"
const baseURL = process.env.BASE_URL

const retries = process.env.PLAYWRIGHT_RETRIES ? parseInt(process.env.PLAYWRIGHT_RETRIES) : undefined
const video = process.env.PLAYWRIGHT_VIDEO ? (process.env.PLAYWRIGHT_VIDEO as VideoMode) : undefined
const timeout = process.env.PLAYWRIGHT_TIMEOUT ? parseInt(process.env.PLAYWRIGHT_TIMEOUT) : 300000
const workers = process.env.PLAYWRIGHT_WORKERS ? parseInt(process.env.PLAYWRIGHT_WORKERS) : 1
const reporter = process.env.PLAYWRIGHT_REPORTER ? JSON.parse(process.env.PLAYWRIGHT_REPORTER) : undefined
const locale = process.env.PLAYWRIGHT_LOCALE ? process.env.PLAYWRIGHT_LOCALE : undefined
const timezoneId = process.env.PLAYWRIGHT_TIMEZONE ? process.env.PLAYWRIGHT_TIMEZONE : undefined
const colorScheme = process.env.PLAYWRIGHT_COLOR_SCHEME
  ? (process.env.PLAYWRIGHT_COLOR_SCHEME as PlaywrightTestOptions["colorScheme"])
  : undefined
const geolocation = process.env.PLAYWRIGHT_GEOLOCATION
  ? (JSON.parse(process.env.PLAYWRIGHT_GEOLOCATION) as PlaywrightTestOptions["geolocation"])
  : undefined
const permissions = process.env.PLAYWRIGHT_PERMISSIONS
  ? (JSON.parse(process.env.PLAYWRIGHT_PERMISSIONS) as PlaywrightTestOptions["permissions"])
  : undefined
const userAgent = process.env.PLAYWRIGHT_USER_AGENT ? process.env.PLAYWRIGHT_USER_AGENT : undefined
const offline = process.env.PLAYWRIGHT_OFFLINE ? process.env.PLAYWRIGHT_OFFLINE === "true" : undefined
const viewport = process.env.PLAYWRIGHT_VIEWPORT
  ? (JSON.parse(process.env.PLAYWRIGHT_VIEWPORT) as PlaywrightTestOptions["viewport"])
  : undefined

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL,
    headless: false,
    video,
    locale,
    timezoneId,
    colorScheme,
    geolocation,
    permissions,
    userAgent,
    offline,
    viewport,
  },
  globalSetup: require.resolve("./tests/setup"),
  // Output test results to the tested app directory
  outputDir,
  reporter: reporter,
  retries,
  timeout: timeout ?? 300000,
  workers,
})
