import type { ActionParams, ClosePageRequest } from "../contracts"

export async function closePage({ pageManager, params }: ActionParams<ClosePageRequest>) {
  await pageManager.close(params.pageId)
}
