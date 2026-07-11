import {
  defineConfig,
  LaunchOptions,
  PlaywrightTestOptions,
  PlaywrightWorkerOptions,
  ReporterDescription,
  VideoMode,
} from "@playwright/test"

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
const headless = process.env.PATROL_WEB_HEADLESS ? process.env.PATROL_WEB_HEADLESS === "true" : false
const browserArgs = process.env.PATROL_WEB_BROWSER_ARGS
  ? (JSON.parse(process.env.PATROL_WEB_BROWSER_ARGS) as string[])
  : undefined

// Browser launch options.
const channel = process.env.PATROL_WEB_CHANNEL ? process.env.PATROL_WEB_CHANNEL : undefined
const executablePath = process.env.PATROL_WEB_EXECUTABLE_PATH
  ? process.env.PATROL_WEB_EXECUTABLE_PATH
  : undefined
const slowMo = process.env.PATROL_WEB_SLOW_MO ? parseInt(process.env.PATROL_WEB_SLOW_MO) : undefined
const chromiumSandbox = process.env.PATROL_WEB_CHROMIUM_SANDBOX
  ? process.env.PATROL_WEB_CHROMIUM_SANDBOX === "true"
  : undefined
const downloadsPath = process.env.PATROL_WEB_DOWNLOADS_PATH
  ? process.env.PATROL_WEB_DOWNLOADS_PATH
  : undefined
const ignoreDefaultArgs = process.env.PATROL_WEB_IGNORE_DEFAULT_ARGS
  ? process.env.PATROL_WEB_IGNORE_DEFAULT_ARGS === "true"
  : undefined
const proxy = process.env.PATROL_WEB_PROXY
  ? (JSON.parse(process.env.PATROL_WEB_PROXY) as LaunchOptions["proxy"])
  : undefined
const browserTimeout = process.env.PATROL_WEB_BROWSER_TIMEOUT
  ? parseInt(process.env.PATROL_WEB_BROWSER_TIMEOUT)
  : undefined
const tracesDir = process.env.PATROL_WEB_TRACES_DIR ? process.env.PATROL_WEB_TRACES_DIR : undefined

const launchOptions = undefinedIfEmpty<LaunchOptions>({
  args: browserArgs,
  executablePath,
  slowMo,
  chromiumSandbox,
  downloadsPath,
  ignoreDefaultArgs,
  proxy,
  timeout: browserTimeout,
  tracesDir,
})

// Browser context options.
const bypassCSP = process.env.PATROL_WEB_BYPASS_CSP
  ? process.env.PATROL_WEB_BYPASS_CSP === "true"
  : undefined
const ignoreHTTPSErrors = process.env.PATROL_WEB_IGNORE_HTTPS_ERRORS
  ? process.env.PATROL_WEB_IGNORE_HTTPS_ERRORS === "true"
  : undefined
const offline = process.env.PATROL_WEB_OFFLINE ? process.env.PATROL_WEB_OFFLINE === "true" : undefined
const httpCredentials = process.env.PATROL_WEB_HTTP_CREDENTIALS
  ? (JSON.parse(process.env.PATROL_WEB_HTTP_CREDENTIALS) as PlaywrightTestOptions["httpCredentials"])
  : undefined
const extraHTTPHeaders = process.env.PATROL_WEB_EXTRA_HTTP_HEADERS
  ? (JSON.parse(process.env.PATROL_WEB_EXTRA_HTTP_HEADERS) as PlaywrightTestOptions["extraHTTPHeaders"])
  : undefined
const screenshot = process.env.PATROL_WEB_SCREENSHOT
  ? (process.env.PATROL_WEB_SCREENSHOT as PlaywrightWorkerOptions["screenshot"])
  : undefined
const trace = process.env.PATROL_WEB_TRACE
  ? (process.env.PATROL_WEB_TRACE as PlaywrightWorkerOptions["trace"])
  : undefined
const storageState = process.env.PATROL_WEB_STORAGE_STATE ? process.env.PATROL_WEB_STORAGE_STATE : undefined
const acceptDownloads = process.env.PATROL_WEB_ACCEPT_DOWNLOADS
  ? process.env.PATROL_WEB_ACCEPT_DOWNLOADS === "true"
  : undefined

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
    channel,
    bypassCSP,
    ignoreHTTPSErrors,
    offline,
    httpCredentials,
    extraHTTPHeaders,
    screenshot,
    trace,
    storageState,
    acceptDownloads,
    launchOptions,
  },
  globalSetup: require.resolve("./tests/setup"),
  outputDir,
  reporter: reporter ?? [["html", { outputFolder, open: "never" }]],
  retries,
  timeout: timeout ?? 10 * 60 * 1000,
  globalTimeout: globalTimeout ?? 2 * 60 * 60 * 1000,
  workers,
  fullyParallel: true,
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

function undefinedIfEmpty<T extends object>(obj: T): T | undefined {
  return Object.values(obj).some(value => value !== undefined) ? obj : undefined
}

function parseShard(shardValue: string) {
  const [current, total] = shardValue.split("/").map(Number)
  return { current, total }
}
