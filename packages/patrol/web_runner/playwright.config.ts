import {
  defineConfig,
  LaunchOptions,
  PlaywrightTestOptions,
  PlaywrightWorkerOptions,
  ReporterDescription,
  VideoMode,
} from "@playwright/test"

const outputDir = envString("PATROL_TEST_RESULTS_DIR") ?? "./test-results"
const outputFolder = envString("PATROL_TEST_REPORT_DIR") ?? "./playwright-report"
const baseURL = envString("BASE_URL")

const retries = envInt("PATROL_WEB_RETRIES")
const video = envString("PATROL_WEB_VIDEO") as VideoMode | undefined
const timeout = envInt("PATROL_WEB_TIMEOUT") ?? 10 * 60 * 1000
const globalTimeout = envInt("PATROL_WEB_GLOBAL_TIMEOUT") ?? 2 * 60 * 60 * 1000
const workers = envInt("PATROL_WEB_WORKERS") ?? 1

const reporter = envParsed("PATROL_WEB_REPORTER", value => mapReporters(value, outputFolder)) ?? [["html", { outputFolder, open: "never" }]]
const locale = envString("PATROL_WEB_LOCALE")
const timezoneId = envString("PATROL_WEB_TIMEZONE")
const colorScheme = envString("PATROL_WEB_COLOR_SCHEME") as PlaywrightTestOptions["colorScheme"] | undefined
const geolocation = envJson<PlaywrightTestOptions["geolocation"]>("PATROL_WEB_GEOLOCATION")
const permissions = envJson<PlaywrightTestOptions["permissions"]>("PATROL_WEB_PERMISSIONS")
const userAgent = envString("PATROL_WEB_USER_AGENT")
const viewport = envJson<PlaywrightTestOptions["viewport"]>("PATROL_WEB_VIEWPORT")
const shard = envParsed("PATROL_WEB_SHARD", parseShard)
const headless = envBool("PATROL_WEB_HEADLESS") ?? false
const channel = envString("PATROL_WEB_CHANNEL")
const bypassCSP = envBool("PATROL_WEB_BYPASS_CSP")
const ignoreHTTPSErrors = envBool("PATROL_WEB_IGNORE_HTTPS_ERRORS")
const offline = envBool("PATROL_WEB_OFFLINE")
const httpCredentials = envJson<PlaywrightTestOptions["httpCredentials"]>("PATROL_WEB_HTTP_CREDENTIALS")
const extraHTTPHeaders = envJson<PlaywrightTestOptions["extraHTTPHeaders"]>("PATROL_WEB_EXTRA_HTTP_HEADERS")
const screenshot = envString("PATROL_WEB_SCREENSHOT") as PlaywrightWorkerOptions["screenshot"] | undefined
const trace = envString("PATROL_WEB_TRACE") as PlaywrightWorkerOptions["trace"] | undefined
const storageState = envString("PATROL_WEB_STORAGE_STATE")
const acceptDownloads = envBool("PATROL_WEB_ACCEPT_DOWNLOADS")

const launchOptions: LaunchOptions = {
  args: envJson<string[]>("PATROL_WEB_BROWSER_ARGS"),
  executablePath: envString("PATROL_WEB_EXECUTABLE_PATH"),
  slowMo: envInt("PATROL_WEB_SLOW_MO"),
  chromiumSandbox: envBool("PATROL_WEB_CHROMIUM_SANDBOX"),
  downloadsPath: envString("PATROL_WEB_DOWNLOADS_PATH"),
  ignoreDefaultArgs: envParsed("PATROL_WEB_IGNORE_DEFAULT_ARGS", parseIgnoreDefaultArgs),
  proxy: envJson<LaunchOptions["proxy"]>("PATROL_WEB_PROXY"),
  timeout: envInt("PATROL_WEB_BROWSER_TIMEOUT"),
  tracesDir: envString("PATROL_WEB_TRACES_DIR"),
}

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
  reporter,
  retries,
  timeout,
  globalTimeout,
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

function envString(name: string): string | undefined {
  return process.env[name] || undefined
}

function envParsed<T>(name: string, parse: (value: string) => T): T | undefined {
  const value = process.env[name]
  return value ? parse(value) : undefined
}

function envInt(name: string): number | undefined {
  return envParsed(name, value => parseInt(value))
}

function envBool(name: string): boolean | undefined {
  return envParsed(name, value => value === "true")
}

function envJson<T>(name: string): T | undefined {
  return envParsed(name, value => JSON.parse(value) as T)
}

function parseIgnoreDefaultArgs(value: string): LaunchOptions["ignoreDefaultArgs"] {
  if (value === "true" || value === "false") {
    return value === "true"
  }

  const parsed: unknown = JSON.parse(value)
  if (!Array.isArray(parsed) || parsed.some(arg => typeof arg !== "string")) {
    throw new Error("PATROL_WEB_IGNORE_DEFAULT_ARGS must be 'true', 'false' or a JSON array of strings")
  }

  return parsed
}


function parseShard(shardValue: string) {
  const [current, total] = shardValue.split("/").map(Number)
  return { current, total }
}
