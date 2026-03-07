import type { BrowserContext, Page } from "playwright"
import type { WaitForPopupRequest } from "../contracts"
import type { PageManager } from "../pageManager"
import { actions } from "../actions"
import { logger } from "../logger"

export async function waitForPopup(
  page: Page,
  params: WaitForPopupRequest["params"],
  pageManager: PageManager,
  context: BrowserContext,
): Promise<string> {
  const actionFn = actions[params.triggerAction as keyof typeof actions]
  if (!actionFn) {
    throw new Error(`Unknown trigger action: "${params.triggerAction}"`)
  }

  const [newPage] = await Promise.all([
    context.waitForEvent("page"),
    (actionFn as Function)(page, params.triggerParams, pageManager, context).catch((err: unknown) => {
      logger.warn(`Trigger action "${params.triggerAction}" failed: ${err}`)
    }),
  ])

  const tabId = pageManager.idOf(newPage as Page)
  if (!tabId) {
    throw new Error("Popup page was not registered by PageManager")
  }
  return tabId
}
