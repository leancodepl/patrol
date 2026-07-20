import type { ActionParams, SwitchToPageRequest } from "../contracts"

export async function switchToPage({ pageManager, params }: ActionParams<SwitchToPageRequest>) {
  pageManager.activeId = params.pageId
  await pageManager.activePage.bringToFront()
}
