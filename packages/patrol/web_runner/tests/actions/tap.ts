import { FrameLocator, Page } from "playwright"
import { TapRequest } from "../contracts"
import { parseWebSelector } from "../parseWebSelector"

export async function tap(page: Page, params: TapRequest["params"]) {
  let context: FrameLocator | Page = page

  if (params.iframeSelector) {
    const iframeLocator = parseWebSelector(page, params.iframeSelector)
    context = iframeLocator.contentFrame()
    if (!context) throw new Error("Iframe not found")
  }

  const locator = parseWebSelector(context, params.selector)
  await locator.click()
}
