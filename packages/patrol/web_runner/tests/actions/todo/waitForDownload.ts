import { Page } from "playwright"
import { WaitForDownloadRequest } from "../../contracts"

export async function waitForDownload(page: Page, params: WaitForDownloadRequest["params"]): Promise<string> {
  const downloadPromise = page.waitForEvent("download", {
    timeout: params.timeoutMs,
  })
  const download = await downloadPromise
  return download.suggestedFilename()
}
