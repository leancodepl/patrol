import type { ActionParams, ClosePageRequest } from "../contracts"

export async function closePage({ pageManager, params }: ActionParams<ClosePageRequest>) {
  if (pageManager.isMainPageId(params.pageId)) {
    throw new Error("Cannot close the main Flutter page")
  }

  const page = pageManager.resolve(params.pageId)
  await page.close()
}
