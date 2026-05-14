import type { AcceptNextDialogRequest, ActionParams } from "../contracts"

export async function acceptNextDialog({ pageManager }: ActionParams<AcceptNextDialogRequest>) {
  return new Promise(resolve => {
    pageManager.activePage.once("dialog", async dialog => {
      const message = dialog.message()
      await dialog.accept()
      resolve(message)
    })
  })
}
