import { Page } from "playwright"

export async function dismissNextDialog(page: Page) {
  return new Promise(resolve => {
    page.once("dialog", async dialog => {
      const message = dialog.message()
      await dialog.dismiss()
      resolve(message)
    })
  })
}
