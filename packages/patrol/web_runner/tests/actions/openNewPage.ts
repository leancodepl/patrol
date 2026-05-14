import type { ActionParams, OpenNewPageRequest } from "../contracts"

export async function openNewPage({ pageManager, params }: ActionParams<OpenNewPageRequest>): Promise<string> {
  const newPage = await pageManager.context.newPage()
  await newPage.goto(params.url)
  return pageManager.idOf(newPage)!
}
