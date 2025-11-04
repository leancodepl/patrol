import { Page } from "playwright"
import { disableDarkMode } from "./actions/disableDarkMode"
import { enableDarkMode } from "./actions/enableDarkMode"
import { grantPermissions } from "./actions/grantPermissions"
import { PatrolNativeRequest } from "./contracts"
import { logger } from "./logger"

export async function exposePatrolPlatformHandler(page: Page) {
  await page.exposeBinding("__patrol__platformHandler", async ({ page }, request) =>
    handlePatrolPlatformAction(page, request),
  )
}

async function handlePatrolPlatformAction(page: Page, { action, params }: PatrolNativeRequest) {
  logger.info(params, `Received action: ${action}`)

  try {
    switch (action) {
      case "grantPermissions":
        await grantPermissions(page, params)
        break
      case "enableDarkMode":
        await enableDarkMode(page)
        break
      case "disableDarkMode":
        await disableDarkMode(page)
        break
      default:
        logger.error(`Unknown action received: ${action}`)
        throw new Error(`Unknown action received: ${action}`)
    }
  } catch (e) {
    logger.error(e, "Failed to handle patrol platform request")
    throw e
  }
}
