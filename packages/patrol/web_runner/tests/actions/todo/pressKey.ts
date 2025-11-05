import { Page } from "playwright"
import { PressKeyRequest } from "../../contracts"

export async function pressKey(page: Page, params: PressKeyRequest["params"]) {
  await page.keyboard.press(params.key)
}
