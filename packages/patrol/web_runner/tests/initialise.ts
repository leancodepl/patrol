import { Page } from "@playwright/test"

export async function initialise(page: Page) {
  await page.evaluate(() => {
    window.__patrol__isInitialised = true
  })

  await page.waitForFunction(
    () => {
      if (!window.__patrol__onInitialised) return false

      window.__patrol__onInitialised()

      return true
    },
    // Time-based polling instead of the default `requestAnimationFrame`
    // polling, which is paused while the page/tab is not visible and can hang
    // this wait in headed runs. See
    // https://github.com/leancodepl/patrol/issues/3132.
    { timeout: 60000, polling: 100 },
  )
}
