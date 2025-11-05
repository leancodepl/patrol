import { Page } from "playwright"
import { EnterTextRequest } from "../../contracts"
import { parseWebSelector } from "../../parseWebSelector"

export async function enterText(page: Page, params: EnterTextRequest["params"]) {
  const locator = parseWebSelector(page, params.selector)
  await locator.fill(params.text)
}
