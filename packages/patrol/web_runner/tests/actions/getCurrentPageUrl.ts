import type { ActionParams, GetCurrentPageUrlRequest } from "../contracts"

export async function getCurrentPageUrl({ pageManager }: ActionParams<GetCurrentPageUrlRequest>) {
  return pageManager.activePage.url()
}
