import { Page } from "playwright"
import { actions } from "./actions"
import { PatrolNativeRequest } from "./contracts"
import { logger } from "./logger"

export async function exposePatrolPlatformHandler(page: Page) {
  await page.exposeBinding("__patrol__platformHandler", async ({ page }, request) =>
    handlePatrolPlatformAction(page, request),
  )
}

async function handlePatrolPlatformAction(page: Page, { action, params }: PatrolNativeRequest) {
  logger.info(params, `Received action: ${action}`)

  const actionFn = actions[action as keyof typeof actions]

  if (!actionFn) {
    throw new Error(`Action ${action} not found`)
  }

  try {
    return await actionFn(page, params as any)
  } catch (e) {
    logger.error(e, "Failed to handle patrol platform request")
  }
}
