import { BrowserContext } from "playwright"
import { actions } from "./actions"
import { PatrolNativeRequest } from "./contracts"
import { logger } from "./logger"
import { PageManager } from "./pageManager"

export async function exposePatrolPlatformHandler(context: BrowserContext, pageManager: PageManager) {
  await context.exposeBinding("__patrol__platformHandler", async ({ page }, request) => {
    if (!pageManager.isMainPage(page)) {
      throw new Error(`Unauthorized: only the main test page can call the platform handler`)
    }

    return handlePatrolPlatformAction(pageManager, request)
  })
}

export async function handlePatrolPlatformAction(pageManager: PageManager, { action, params }: PatrolNativeRequest) {
  logger.info(params, `Received action: ${action}`)

  const actionFn = actions[action as keyof typeof actions]

  if (!actionFn) {
    throw new Error(`Action ${action} not found`)
  }

  try {
    return await actionFn({ pageManager, params: params as any })
  } catch (e) {
    logger.error(e, "Failed to handle patrol platform request")
    throw e
  }
}
