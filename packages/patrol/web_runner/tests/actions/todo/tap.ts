import { Page } from "playwright"
import { TapRequest } from "../../contracts"
import { parseWebSelector } from "../../parseWebSelector"

export async function tap(page: Page, params: TapRequest["params"]) {
  const locator = parseWebSelector(page, params)
  await locator.click()
}
