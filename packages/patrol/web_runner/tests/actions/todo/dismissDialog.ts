import { Page } from "playwright"

export async function dismissDialog(page: Page) {
  page.once("dialog", async dialog => {
    await dialog.dismiss()
  })
}
