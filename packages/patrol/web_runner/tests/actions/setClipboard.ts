import { Page } from "playwright"
import { SetClipboardRequest } from "../contracts"

export async function setClipboard(page: Page, params: SetClipboardRequest["params"]) {
  await page.evaluate(text => navigator.clipboard.writeText(text), params.text)
}
