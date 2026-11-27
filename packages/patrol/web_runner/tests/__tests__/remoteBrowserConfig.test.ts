import { expect, test } from "@playwright/test"
import type { PlaywrightTestConfig } from "@playwright/test"

const configPath = require.resolve("../../playwright.config")

const remoteEnvNames = [
  "PATROL_WEB_CONNECT_WS_ENDPOINT",
  "PATROL_WEB_CONNECT_HEADERS",
  "PATROL_WEB_CONNECT_EXPOSE_NETWORK",
  "PATROL_WEB_HEADLESS",
  "PATROL_WEB_BROWSER_TIMEOUT",
  "PATROL_WEB_IGNORE_DEFAULT_ARGS",
]

// The config reads the environment once, at import time, so load a fresh copy
// for every combination of variables.
function loadConfig(env: Record<string, string>): PlaywrightTestConfig {
  const saved = Object.fromEntries(remoteEnvNames.map(name => [name, process.env[name]]))
  try {
    for (const name of remoteEnvNames) delete process.env[name]
    Object.assign(process.env, env)
    delete require.cache[configPath]
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return (require(configPath) as { default: PlaywrightTestConfig }).default
  } finally {
    for (const [name, value] of Object.entries(saved)) {
      if (value === undefined) delete process.env[name]
      else process.env[name] = value
    }
  }
}

test("launches a local, headed browser when no endpoint is set", () => {
  const { use } = loadConfig({})

  expect(use?.connectOptions).toBeUndefined()
  expect(use?.headless).toBe(false)
})

test("connects to the endpoint and exposes loopback by default", () => {
  const { use } = loadConfig({ PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/" })

  expect(use?.connectOptions).toEqual({
    wsEndpoint: "ws://127.0.0.1:3000/",
    headers: undefined,
    exposeNetwork: "<loopback>",
    timeout: undefined,
  })
})

test("runs headless on a remote browser unless told otherwise", () => {
  expect(loadConfig({ PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/" }).use?.headless).toBe(true)
  expect(
    loadConfig({ PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/", PATROL_WEB_HEADLESS: "false" }).use?.headless,
  ).toBe(false)
})

test("passes connect headers and a custom exposeNetwork through", () => {
  const { use } = loadConfig({
    PATROL_WEB_CONNECT_WS_ENDPOINT: "wss://grid.example.com/playwright",
    PATROL_WEB_CONNECT_HEADERS: '{"Authorization":"Bearer token"}',
    PATROL_WEB_CONNECT_EXPOSE_NETWORK: "localhost,*.test",
  })

  expect(use?.connectOptions).toEqual({
    wsEndpoint: "wss://grid.example.com/playwright",
    headers: { Authorization: "Bearer token" },
    exposeNetwork: "localhost,*.test",
    timeout: undefined,
  })
})

test("ignores connect headers without an endpoint", () => {
  const { use } = loadConfig({ PATROL_WEB_CONNECT_HEADERS: '{"Authorization":"Bearer token"}' })

  expect(use?.connectOptions).toBeUndefined()
})

test("turns the tunnel off when exposeNetwork is empty", () => {
  const { use } = loadConfig({
    PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/",
    PATROL_WEB_CONNECT_EXPOSE_NETWORK: "",
  })

  expect(use?.connectOptions?.exposeNetwork).toBe("")
})

test("uses the browser timeout as the connection timeout", () => {
  const { use } = loadConfig({
    PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/",
    PATROL_WEB_BROWSER_TIMEOUT: "15000",
  })

  expect(use?.connectOptions?.timeout).toBe(15000)
})

for (const headers of ["token", "[]", '"Bearer token"', '{"Authorization": 1}', "null"]) {
  test(`rejects connect headers ${headers}`, () => {
    expect(() =>
      loadConfig({ PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/", PATROL_WEB_CONNECT_HEADERS: headers }),
    ).toThrow("PATROL_WEB_CONNECT_HEADERS must be a JSON object with string values")
  })
}

test("rejects ignoreDefaultArgs true with a remote browser", () => {
  expect(() =>
    loadConfig({ PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/", PATROL_WEB_IGNORE_DEFAULT_ARGS: "true" }),
  ).toThrow("--web-ignore-default-args true isn't supported with a remote browser")
})

test("allows a list of default args to skip with a remote browser", () => {
  const { use } = loadConfig({
    PATROL_WEB_CONNECT_WS_ENDPOINT: "ws://127.0.0.1:3000/",
    PATROL_WEB_IGNORE_DEFAULT_ARGS: '["--mute-audio"]',
  })

  expect(use?.launchOptions?.ignoreDefaultArgs).toEqual(["--mute-audio"])
})

test("still allows ignoreDefaultArgs true with a local browser", () => {
  const { use } = loadConfig({ PATROL_WEB_IGNORE_DEFAULT_ARGS: "true" })

  expect(use?.launchOptions?.ignoreDefaultArgs).toBe(true)
})
