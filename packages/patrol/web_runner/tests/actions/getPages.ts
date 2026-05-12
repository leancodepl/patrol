import type { ActionParams, GetPagesRequest } from "../contracts"

export async function getPages({ pageManager }: ActionParams<GetPagesRequest>) {
  return pageManager.ids
}
