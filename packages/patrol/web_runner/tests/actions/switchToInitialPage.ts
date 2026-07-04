import type { ActionParams, SwitchToInitialPageRequest } from "../contracts"
import { switchToPage } from "./switchToPage"

export async function switchToInitialPage({ pageManager }: ActionParams<SwitchToInitialPageRequest>) {
  await switchToPage({ pageManager, params: { pageId: pageManager.initialPageId } })
}
