import type { Page } from "playwright"
import type { SwitchToTabRequest } from "../contracts"
import type { PageManager } from "../pageManager"

export async function switchToTab(
  _page: Page,
  params: SwitchToTabRequest["params"],
  pageManager: PageManager,
): Promise<void> {
  pageManager.activeId = params.tabId
  const page = pageManager.resolve(params.tabId)
  await page.bringToFront()
}
