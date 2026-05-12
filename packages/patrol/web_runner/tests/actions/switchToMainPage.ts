import type { ActionParams, SwitchToMainPageRequest } from "../contracts"
import { switchToPage } from "./switchToPage"

export async function switchToMainPage({ pageManager }: ActionParams<SwitchToMainPageRequest>) {
  await switchToPage({ pageManager, params: { pageId: pageManager.mainPageId } })
}
