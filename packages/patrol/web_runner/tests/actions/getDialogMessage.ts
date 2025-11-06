import { Page } from "playwright"

export async function getDialogMessage(page: Page): Promise<string> {
  return new Promise(resolve => {
    page.once("dialog", async dialog => {
      const message = dialog.message()
      await dialog.accept()
      resolve(message)
    })
  })
}
