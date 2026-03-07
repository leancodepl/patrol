import { Page } from "playwright"
import { logger } from "../logger"

export const downloadedFiles: string[] = []
const initializedPages = new WeakSet<Page>()

function registerDownloadListener(page: Page) {
  if (!initializedPages.has(page)) {
    initializedPages.add(page)
    page.on("download", async download => {
      const filename = download.suggestedFilename()
      downloadedFiles.push(filename)
      logger.info(`File downloaded: ${filename}`)
    })
  }
}

export async function startTest(page: Page) {
  downloadedFiles.splice(0, downloadedFiles.length)
  registerDownloadListener(page)

  // Register on all currently tracked pages from the context
  const context = page.context()
  for (const p of context.pages()) {
    registerDownloadListener(p)
  }

  // Listen for future pages in this context
  context.on("page", (newPage: Page) => {
    registerDownloadListener(newPage)
  })
}
