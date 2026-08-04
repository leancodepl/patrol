import type { ActionParams, DismissNextDialogRequest } from "../contracts"

export async function dismissNextDialog({ pageManager }: ActionParams<DismissNextDialogRequest>) {
  return new Promise(resolve => {
    pageManager.activePage.once("dialog", async dialog => {
      const message = dialog.message()
      await dialog.dismiss()
      resolve(message)
    })
  })
}
