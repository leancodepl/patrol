import { Page } from "playwright"

export async function acceptDialog(page: Page) {
  page.once("dialog", async dialog => {
    await dialog.accept()
  })
}
