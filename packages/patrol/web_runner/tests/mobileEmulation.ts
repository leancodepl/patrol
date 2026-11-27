import type { BrowserContext } from "playwright"

type MobileEmulationOptions = {
  userAgent: string | undefined
  isMobile: boolean | undefined
  /** Where the Flutter app is served. */
  baseURL: string | undefined
}

/**
 * Makes the pages of `context` look like the emulated phone to a Flutter app,
 * on top of Playwright's own emulation. Call it before any page in the context
 * loads the app. Does nothing unless the user agent names a mobile OS or
 * `isMobile` is set.
 */
export async function prepareMobileEmulation(
  context: BrowserContext,
  { userAgent, isMobile, baseURL }: MobileEmulationOptions,
): Promise<void> {
  const platform = platformForUserAgent(userAgent)
  const appOrigin = isMobile && baseURL ? new URL(baseURL).origin : undefined

  if (platform === undefined && appOrigin === undefined) {
    return
  }

  await context.addInitScript(mobileEmulationScript, { platform, appOrigin })
}

/**
 * A `navigator.platform` value for which Flutter web detects the same OS as
 * from `userAgent`, or undefined when the user agent names no mobile OS.
 *
 * Playwright changes the user agent but keeps the host's `navigator.platform`
 * ("MacIntel", "Linux x86_64", "Win32"), and Flutter web reads
 * `navigator.platform` before the user agent. Without this, an emulated iPhone
 * is never iOS, and an emulated Android phone is Android on a Linux host but
 * macOS on a Mac. "Linux aarch64" is what Chrome reports on 64-bit Android;
 * Flutter only needs it not to name another OS.
 */
export function platformForUserAgent(userAgent: string | undefined): string | undefined {
  if (!userAgent) return undefined
  if (userAgent.includes("iPhone")) return "iPhone"
  if (userAgent.includes("iPad")) return "iPad"
  if (userAgent.includes("Android")) return "Linux aarch64"
  return undefined
}

// Runs in every frame of every page in the context, before the page's scripts.
function mobileEmulationScript({ platform, appOrigin }: { platform?: string; appOrigin?: string }) {
  if (platform !== undefined) {
    Object.defineProperty(Navigator.prototype, "platform", { get: () => platform, configurable: true })
  }

  // The viewport tag is only for the Flutter app's own page, not for other
  // sites the test opens or for frames inside the app.
  if (appOrigin === undefined || window !== window.top || location.origin !== appOrigin) {
    return
  }

  // Flutter's default `web/index.html` has no viewport meta tag. Under
  // Chromium's mobile emulation the page is then first laid out 980 px wide
  // and zoomed out, until the Flutter engine inserts its own tag and
  // `visualViewport.scale` changes from about 0.4 to 1. The emulation fires a
  // resize then (Chrome 91 on Android didn't, when checked), and while handling
  // it the engine reads the device pixel ratio (which includes the scale)
  // before the browser has applied the new scale. It computes the view's
  // physical size and its keyboard inset with different scales, and in debug
  // builds that fails the assertion "ViewInsets cannot be negative" while the
  // app starts.
  //
  // With the tag in place from the start there is no zoomed-out layout to
  // leave. The engine removes it and appends an identical one. The
  // `flt-viewport` attribute is how the engine marks its own tag (checked with
  // Flutter 3.41), so it is replaced without a warning. A viewport tag the page
  // declares itself is kept.
  const addViewportMeta = () => {
    if (document.head.querySelector('meta[name="viewport"]')) return

    const meta = document.createElement("meta")
    meta.setAttribute("flt-viewport", "")
    meta.name = "viewport"
    meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
    document.head.prepend(meta)
  }

  if (document.head) {
    addViewportMeta()
    return
  }

  // Init scripts run before the HTML is parsed, so wait for <head>.
  const observer = new MutationObserver(() => {
    if (document.head) {
      observer.disconnect()
      addViewportMeta()
    }
  })
  observer.observe(document, { childList: true, subtree: true })
}
