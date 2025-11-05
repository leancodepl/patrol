import { Page } from "playwright"
import { ScrollToRequest } from "../../contracts"
import { parseWebSelector } from "../../parseWebSelector"

export async function scrollTo(page: Page, params: ScrollToRequest["params"]) {
  const locator = parseWebSelector(page, params)
  await locator.scrollIntoViewIfNeeded()
}
