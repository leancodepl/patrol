import type { Page } from "playwright"
import type { GetCurrentTabRequest } from "../contracts"
import type { PageManager } from "../pageManager"

export async function getCurrentTab(
  _page: Page,
  _params: GetCurrentTabRequest["params"],
  pageManager: PageManager,
): Promise<string> {
  return pageManager.activeId
}
