import { defineConfig, PlaywrightTestOptions, VideoMode } from "@playwright/test"

const outputDir = process.env.PATROL_TEST_RESULTS_DIR || "./test-results"
const baseURL = process.env.BASE_URL

const retries = process.env.PATROL_WEB_RETRIES ? parseInt(process.env.PATROL_WEB_RETRIES) : undefined
const video = process.env.PATROL_WEB_VIDEO ? (process.env.PATROL_WEB_VIDEO as VideoMode) : undefined
const timeout = process.env.PATROL_WEB_TIMEOUT ? parseInt(process.env.PATROL_WEB_TIMEOUT) : undefined
const globalTimeout = process.env.PATROL_WEB_GLOBAL_TIMEOUT
  ? parseInt(process.env.PATROL_WEB_GLOBAL_TIMEOUT)
  : undefined
const workers = process.env.PATROL_WEB_WORKERS ? parseInt(process.env.PATROL_WEB_WORKERS) : 1
const reporter = process.env.PATROL_WEB_REPORTER ? JSON.parse(process.env.PATROL_WEB_REPORTER) : undefined
const locale = process.env.PATROL_WEB_LOCALE ? process.env.PATROL_WEB_LOCALE : undefined
const timezoneId = process.env.PATROL_WEB_TIMEZONE ? process.env.PATROL_WEB_TIMEZONE : undefined
const colorScheme = process.env.PATROL_WEB_COLOR_SCHEME
  ? (process.env.PATROL_WEB_COLOR_SCHEME as PlaywrightTestOptions["colorScheme"])
  : undefined
const geolocation = process.env.PATROL_WEB_GEOLOCATION
  ? (JSON.parse(process.env.PATROL_WEB_GEOLOCATION) as PlaywrightTestOptions["geolocation"])
  : undefined
const permissions = process.env.PATROL_WEB_PERMISSIONS
  ? (JSON.parse(process.env.PATROL_WEB_PERMISSIONS) as PlaywrightTestOptions["permissions"])
  : undefined
const userAgent = process.env.PATROL_WEB_USER_AGENT ? process.env.PATROL_WEB_USER_AGENT : undefined
const viewport = process.env.PATROL_WEB_VIEWPORT
  ? (JSON.parse(process.env.PATROL_WEB_VIEWPORT) as PlaywrightTestOptions["viewport"])
  : undefined
const shard = process.env.PATROL_WEB_SHARD
  ? (() => {
      const shardValue = process.env.PATROL_WEB_SHARD
      if (!shardValue) return undefined
      const [current, total] = shardValue.split("/").map(Number)
      return { current, total }
    })()
  : undefined
const fullyParallel = process.env.PATROL_WEB_FULLY_PARALLEL ? process.env.PATROL_WEB_FULLY_PARALLEL === "true" : false
const headless = process.env.PATROL_WEB_HEADLESS ? process.env.PATROL_WEB_HEADLESS === "true" : false

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL,
    headless,
    video,
    locale,
    timezoneId,
    colorScheme,
    geolocation,
    permissions,
    userAgent,
    viewport,
  },
  globalSetup: require.resolve("./tests/setup"),
  // Output test results to the tested app directory
  outputDir,
  reporter,
  retries,
  timeout: timeout ?? 10 * 60 * 1000,
  globalTimeout: globalTimeout ?? 2 * 60 * 60 * 1000,
  workers,
  fullyParallel,
  shard,
})
