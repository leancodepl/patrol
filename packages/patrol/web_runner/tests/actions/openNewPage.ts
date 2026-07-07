import type { ActionParams, OpenNewPageRequest } from "../contracts"

export async function openNewPage({ pageManager, params }: ActionParams<OpenNewPageRequest>): Promise<string> {
  const newPage = await pageManager.context.newPage()
  try {
    await newPage.goto(params.url)
  } catch (e) {
    // Navigation failed: close the just-opened page so it isn't left orphaned
    // (still registered and counted in getPages, but with an ID the caller never received).
    await newPage.close().catch(() => {})
    throw e
  }
  return pageManager.idOf(newPage)!
}
