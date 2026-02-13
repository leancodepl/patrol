import { Page } from "playwright"

export async function acceptNextDialog(page: Page) {
  return new Promise(resolve => {
    page.once("dialog", async dialog => {
      const message = dialog.message()
      await dialog.accept()
      resolve(message)
    })
  })
}
