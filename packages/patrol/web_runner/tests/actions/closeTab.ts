import type { Page } from "playwright"
import type { CloseTabRequest } from "../contracts"
import type { PageManager } from "../pageManager"

export async function closeTab(
  _page: Page,
  params: CloseTabRequest["params"],
  pageManager: PageManager,
): Promise<void> {
  if (params.tabId === "tab_0") {
    throw new Error("Cannot close the initial Flutter tab (tab_0)")
  }
  const page = pageManager.resolve(params.tabId)
  await page.close()
}
