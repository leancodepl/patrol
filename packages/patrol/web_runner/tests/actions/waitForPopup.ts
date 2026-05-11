import type { Page } from "playwright"
import type { ActionParams, WaitForPopupRequest } from "../contracts"
import { actions } from "../actions"
import { logger } from "../logger"

export async function waitForPopup({ pageManager, params }: ActionParams<WaitForPopupRequest>): Promise<string> {
  const actionFn = actions[params.triggerAction as keyof typeof actions]
  if (!actionFn) {
    throw new Error(`Unknown trigger action: "${params.triggerAction}"`)
  }

  const context = pageManager.context

  const [newPage] = await Promise.all([
    context.waitForEvent("page"),
    (actionFn)({ pageManager, params: params.triggerParams as any }).catch((err: unknown) => {
      logger.warn(`Trigger action "${params.triggerAction}" failed: ${err}`)
    }),
  ])

  const tabId = pageManager.idOf(newPage)
  if (!tabId) {
    throw new Error("Popup page was not registered by PageManager")
  }
  return tabId
}
