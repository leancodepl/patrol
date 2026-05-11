import type { FrameLocator, Page } from "playwright"
import type { ActionParams, ScrollToRequest } from "../contracts"
import { parseWebSelector } from "../parseWebSelector"

export async function scrollTo({ pageManager, params }: ActionParams<ScrollToRequest>) {
  let context: FrameLocator | Page = pageManager.activePage

  if (params.iframeSelector) {
    const iframeLocator = parseWebSelector(context, params.iframeSelector)
    context = iframeLocator.contentFrame()
    if (!context) throw new Error("Iframe not found")
  }

  const locator = parseWebSelector(context, params.selector)
  await locator.scrollIntoViewIfNeeded()
}
