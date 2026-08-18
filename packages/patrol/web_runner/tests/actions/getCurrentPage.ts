import type { ActionParams, GetCurrentPageRequest } from "../contracts"

export async function getCurrentPage({ pageManager }: ActionParams<GetCurrentPageRequest>) {
  return pageManager.activeId
}
