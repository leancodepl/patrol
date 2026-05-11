import type { ActionParams, SwitchToMainPageRequest } from "../contracts"

export async function switchToMainPage({ pageManager }: ActionParams<SwitchToMainPageRequest>) {
  const page = pageManager.activePage
  await page.bringToFront()
}
