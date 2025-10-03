import { Page } from "@playwright/test";

export async function initialise(page: Page) {
  await page.evaluate(() => {
    window.__patrol__isInitialised = true;
  });

  await page.waitForFunction(
    () => {
      if (typeof window.__patrol__onInitialised !== "function") return false;

      window.__patrol__onInitialised();

      return true;
    },
    { timeout: 60000 }
  );
}
