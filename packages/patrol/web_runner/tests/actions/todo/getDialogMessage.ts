import { Page } from "playwright"

export async function getDialogMessage(page: Page): Promise<string> {
  return new Promise(resolve => {
    page.once("dialog", dialog => {
      resolve(dialog.message())
    })
  })
}
