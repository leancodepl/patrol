import { Page } from "playwright";
import { grantPermissions } from "./actions/grantPermissions";
import { enableDarkMode } from "./actions/enableDarkMode";
import { disableDarkMode } from "./actions/disableDarkMode";

export async function exposePatrolPlatformHandler(page: Page) {
  await page.exposeBinding(
    "__patrol__platformHandler",
    async ({ page }, request) => handlePatrolPlatformAction(page, request)
  );
}

async function handlePatrolPlatformAction(
  page: Page,
  { action, params }: PatrolNativeRequest
) {
  console.log(`Received action: ${action}`, params);

  try {
    switch (action) {
      case "grantPermissions":
        await grantPermissions(page, params);
        break;
      case "enableDarkMode":
        await enableDarkMode(page);
        break;
      case "disableDarkMode":
        await disableDarkMode(page);
        break;
      default:
        console.error(`Unknown action received: ${action}`);
        throw new Error(`Unknown action received: ${action}`);
    }
  } catch (e) {
    console.error("Failed to handle patrol platform request", e);
    throw e;
  }
}
