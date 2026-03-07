import type { Page } from "playwright"
import type { GetTabsRequest } from "../contracts"
import type { PageManager } from "../pageManager"

export async function getTabs(
  _page: Page,
  _params: GetTabsRequest["params"],
  pageManager: PageManager,
): Promise<{ tabs: string[]; activeTabId: string }> {
  return { tabs: pageManager.ids, activeTabId: pageManager.activeId }
}
