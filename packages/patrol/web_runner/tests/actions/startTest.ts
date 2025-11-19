import { Page } from "playwright"
import { logger } from "../logger"

export const downloadedFiles: string[] = []
const initializedPages = new WeakSet<Page>()

export async function startTest(page: Page) {
  downloadedFiles.splice(0, downloadedFiles.length)

  if (!initializedPages.has(page)) {
    initializedPages.add(page)
    page.on("download", async download => {
      const filename = download.suggestedFilename()
      downloadedFiles.push(filename)
      logger.info(`File downloaded: ${filename}`)
    })
  }
}
