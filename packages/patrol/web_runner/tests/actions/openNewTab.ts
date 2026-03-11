import type { BrowserContext, Page } from "playwright"
import type { OpenNewTabRequest } from "../contracts"
import type { PageManager } from "../pageManager"

export async function openNewTab(
  _page: Page,
  params: OpenNewTabRequest["params"],
  pageManager: PageManager,
  context: BrowserContext,
): Promise<string> {
  const newPage = await context.newPage()
  await newPage.goto(params.url)
  return pageManager.idOf(newPage)!
}
