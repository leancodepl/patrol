import { Page } from "playwright"
import { logger } from "../logger"

export const downloadedFiles: string[] = []
let isInitialized = false

export async function startTest(page: Page) {
  downloadedFiles.splice(0, downloadedFiles.length)

  if (!isInitialized) {
    isInitialized = true
    page.on("download", async download => {
      const filename = download.suggestedFilename()
      downloadedFiles.push(filename)
      logger.info(`File downloaded: ${filename}`)
    })
  }
}
