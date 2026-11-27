import { devices, expect, test, type PlaywrightTestConfig } from "@playwright/test"
import { platformForUserAgent } from "../mobileEmulation"

const configPath = require.resolve("../../playwright.config")

// playwright.config.ts reads PATROL_WEB_* once, at import time. Load a fresh
// copy with only the given variables set.
function loadConfig(env: Record<string, string>): PlaywrightTestConfig {
  const savedEnv = process.env
  process.env = Object.fromEntries(Object.entries(savedEnv).filter(([key]) => !key.startsWith("PATROL_WEB_")))
  Object.assign(process.env, env)

  try {
    delete require.cache[configPath]
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return (require(configPath) as { default: PlaywrightTestConfig }).default
  } finally {
    process.env = savedEnv
    delete require.cache[configPath]
  }
}

test("leaves device emulation unset by default", () => {
  const { use } = loadConfig({})

  expect(use?.userAgent).toBeUndefined()
  expect(use?.viewport).toBeUndefined()
  expect(use?.deviceScaleFactor).toBeUndefined()
  expect(use?.isMobile).toBeUndefined()
  expect(use?.hasTouch).toBeUndefined()
  expect(use?.contextOptions).toBeUndefined()
})

test("fills emulation options from a device", () => {
  const { use } = loadConfig({ PATROL_WEB_DEVICE: "Pixel 7" })
  const pixel7 = devices["Pixel 7"]

  expect(use?.userAgent).toBe(pixel7.userAgent)
  expect(use?.viewport).toEqual(pixel7.viewport)
  expect(use?.deviceScaleFactor).toBe(pixel7.deviceScaleFactor)
  expect(use?.isMobile).toBe(true)
  expect(use?.hasTouch).toBe(true)
})

test("passes the device's screen size as a context option", () => {
  const { use } = loadConfig({ PATROL_WEB_DEVICE: "Pixel 7" })

  expect(use?.contextOptions).toEqual({ screen: { width: 412, height: 915 } })
})

test("keeps an explicit null viewport", () => {
  expect(loadConfig({ PATROL_WEB_VIEWPORT: "null" }).use?.viewport).toBeNull()

  const { use } = loadConfig({ PATROL_WEB_DEVICE: "Desktop Chrome", PATROL_WEB_VIEWPORT: "null" })
  expect(use?.viewport).toBeNull()
  // A screen size needs a fixed viewport.
  expect(use?.contextOptions).toBeUndefined()
})

test("drops the device's scale factor and mobile mode with a null viewport", () => {
  // Playwright rejects both without a fixed viewport.
  const { use } = loadConfig({ PATROL_WEB_DEVICE: "Pixel 7", PATROL_WEB_VIEWPORT: "null" })

  expect(use?.viewport).toBeNull()
  expect(use?.deviceScaleFactor).toBeUndefined()
  expect(use?.isMobile).toBeUndefined()
  expect(use?.contextOptions).toBeUndefined()
  // The rest of the device still applies.
  expect(use?.userAgent).toBe(devices["Pixel 7"].userAgent)
  expect(use?.hasTouch).toBe(true)
})

test("does not let a device pick the browser", () => {
  // The iPhone descriptors default to WebKit.
  const { use } = loadConfig({ PATROL_WEB_DEVICE: "iPhone 15" })

  expect(use?.browserName).toBeUndefined()
  expect(use).not.toHaveProperty("defaultBrowserType")
})

test("lets explicit options override the device", () => {
  const { use } = loadConfig({
    PATROL_WEB_DEVICE: "Pixel 7",
    PATROL_WEB_USER_AGENT: "custom-agent",
    PATROL_WEB_VIEWPORT: '{"width":800,"height":600}',
    PATROL_WEB_DEVICE_SCALE_FACTOR: "1.5",
    PATROL_WEB_IS_MOBILE: "false",
    PATROL_WEB_HAS_TOUCH: "false",
  })

  expect(use?.userAgent).toBe("custom-agent")
  expect(use?.viewport).toEqual({ width: 800, height: 600 })
  expect(use?.deviceScaleFactor).toBe(1.5)
  expect(use?.isMobile).toBe(false)
  expect(use?.hasTouch).toBe(false)
})

test("accepts emulation options without a device", () => {
  const { use } = loadConfig({ PATROL_WEB_HAS_TOUCH: "true", PATROL_WEB_DEVICE_SCALE_FACTOR: "2" })

  expect(use?.hasTouch).toBe(true)
  expect(use?.deviceScaleFactor).toBe(2)
  expect(use?.isMobile).toBeUndefined()
})

test("names similar devices when the device is unknown", () => {
  expect(() => loadConfig({ PATROL_WEB_DEVICE: "pixel" })).toThrow(
    /PATROL_WEB_DEVICE: unknown device "pixel"\. Similar names: "Pixel 2"/,
  )
})

test("rejects names that are not devices", () => {
  expect(() => loadConfig({ PATROL_WEB_DEVICE: "toString" })).toThrow(/unknown device "toString"/)
})

test("rejects an unknown device with no similar names", () => {
  expect(() => loadConfig({ PATROL_WEB_DEVICE: "Nokia 3310" })).toThrow(
    /^PATROL_WEB_DEVICE: unknown device "Nokia 3310"\. See https:\/\/playwright\.dev\/docs\/emulation#devices/,
  )
})

for (const value of ["0", "-1", "abc"]) {
  test(`rejects device scale factor "${value}"`, () => {
    expect(() => loadConfig({ PATROL_WEB_DEVICE_SCALE_FACTOR: value })).toThrow(
      "PATROL_WEB_DEVICE_SCALE_FACTOR must be a positive number",
    )
  })
}

test("maps the user agents of mobile devices to their navigator.platform", () => {
  expect(platformForUserAgent(devices["iPhone 15"].userAgent)).toBe("iPhone")
  expect(platformForUserAgent(devices["iPad Pro 11"].userAgent)).toBe("iPad")
  expect(platformForUserAgent(devices["Pixel 7"].userAgent)).toBe("Linux aarch64")
  expect(platformForUserAgent(devices["Galaxy S9+"].userAgent)).toBe("Linux aarch64")
})

test("keeps the host platform for other user agents", () => {
  expect(platformForUserAgent(undefined)).toBeUndefined()
  expect(platformForUserAgent(devices["Desktop Chrome"].userAgent)).toBeUndefined()
  expect(platformForUserAgent("custom-agent")).toBeUndefined()
})
