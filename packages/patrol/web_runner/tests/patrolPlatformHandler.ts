import { BrowserContext } from "playwright"
import { actions } from "./actions"
import { PatrolNativeRequest } from "./contracts"
import { logger } from "./logger"
import { PageManager } from "./pageManager"

export async function exposePatrolPlatformHandler(context: BrowserContext, pageManager: PageManager) {
  await context.exposeBinding("__patrol__platformHandler", async ({ page }, request) => {
    if (pageManager.idOf(page) !== "tab_0") {
      throw new Error("Unauthorized: only the main test page (tab_0) can call the platform handler")
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

  const { _routeToTab, ...cleanParams } = params as Record<string, unknown>
  const page = pageManager.resolve(_routeToTab as string | undefined)

  try {
    return await actionFn(page, cleanParams as any, pageManager, pageManager.context)
  } catch (e) {
    logger.error(e, "Failed to handle patrol platform request")
    throw e
  }
}
