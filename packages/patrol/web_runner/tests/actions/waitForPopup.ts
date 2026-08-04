import type { ActionParams, WaitForPopupRequest } from "../contracts"

export async function waitForPopup({ pageManager }: ActionParams<WaitForPopupRequest>): Promise<string> {
  return new Promise((resolve, reject) => {
    pageManager.context.once("page", async page => {
      const tabId = pageManager.idOf(page)

      if (!tabId) {
        reject(new Error("Popup page was not registered by PageManager"))
        return
      }

      resolve(tabId)
    })
  })
}
