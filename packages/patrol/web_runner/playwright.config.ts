import { defineConfig, PlaywrightTestOptions, ReporterDescription, VideoMode } from "@playwright/test"

const outputDir = process.env.PATROL_TEST_RESULTS_DIR || "./test-results"
const outputFolder = process.env.PATROL_TEST_REPORT_DIR || "./playwright-report"
const baseURL = process.env.BASE_URL

const retries = process.env.PATROL_WEB_RETRIES ? parseInt(process.env.PATROL_WEB_RETRIES) : undefined
const video = process.env.PATROL_WEB_VIDEO ? (process.env.PATROL_WEB_VIDEO as VideoMode) : undefined
const timeout = process.env.PATROL_WEB_TIMEOUT ? parseInt(process.env.PATROL_WEB_TIMEOUT) : undefined
const globalTimeout = process.env.PATROL_WEB_GLOBAL_TIMEOUT
  ? parseInt(process.env.PATROL_WEB_GLOBAL_TIMEOUT)
  : undefined
const workers = process.env.PATROL_WEB_WORKERS ? parseInt(process.env.PATROL_WEB_WORKERS) : 1

const reporter = process.env.PATROL_WEB_REPORTER
  ? mapReporters(process.env.PATROL_WEB_REPORTER, outputFolder)
  : undefined
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
const shard = process.env.PATROL_WEB_SHARD ? parseShard(process.env.PATROL_WEB_SHARD) : undefined
const fullyParallel = process.env.PATROL_WEB_FULLY_PARALLEL ? process.env.PATROL_WEB_FULLY_PARALLEL === "true" : false
const headless = process.env.PATROL_WEB_HEADLESS ? process.env.PATROL_WEB_HEADLESS === "true" : false

export default defineConfig({
  use: {
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
  outputDir,
  reporter: reporter ?? [["html", { outputFolder, open: "never" }]],
  retries,
  timeout: timeout ?? 10 * 60 * 1000,
  globalTimeout: globalTimeout ?? 2 * 60 * 60 * 1000,
  workers,
  fullyParallel,
  shard,
})

function mapReporters(reporterEnv: string, outputFolder: string) {
  const reporterNames: unknown = JSON.parse(reporterEnv)

  if (!Array.isArray(reporterNames)) {
    throw new Error("PATROL_WEB_REPORTER must be a JSON array of reporter names")
  }

  return reporterNames.map(name => {
    switch (name) {
      case "html":
        return ["html", { outputFolder, open: "never" }] satisfies ReporterDescription
      case "json":
        return ["json", { outputFile: `${outputFolder}/results.json` }] satisfies ReporterDescription
      case "junit":
        return ["junit", { outputFile: `${outputFolder}/results.xml` }] satisfies ReporterDescription
      case "list":
      case "dot":
      case "line":
      case "github":
      case "null":
        return [name] satisfies ReporterDescription
      default:
        throw new Error(`Unsupported reporter: ${name}`)
    }
  })
}

function parseShard(shardValue: string) {
  const [current, total] = shardValue.split("/").map(Number)
  return { current, total }
}
