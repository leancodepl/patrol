import type { BrowserContext, Page } from "playwright"
import { logger } from "../logger"
import type { ActionParams, StartTestRequest } from "../contracts"

export const downloadedFiles: string[] = []
const initializedPages = new WeakSet<Page>()
const contextsWithPageListener = new WeakSet<BrowserContext>()

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

export async function startTest({ pageManager }: ActionParams<StartTestRequest>) {
  downloadedFiles.splice(0, downloadedFiles.length)
  registerDownloadListener(pageManager.activePage)

  // Register on all currently tracked pages from the context
  const context = pageManager.context
  for (const p of context.pages()) {
    registerDownloadListener(p)
  }

  // Listen for future pages in this context. Attach the listener only once per
  // context: startTest runs once per test, and on a reused/long-lived context
  // (e.g. develop mode) re-adding it every call leaks listeners and eventually
  // trips Node's MaxListenersExceededWarning.
  if (!contextsWithPageListener.has(context)) {
    contextsWithPageListener.add(context)
    context.on("page", newPage => {
      registerDownloadListener(newPage)
    })
  }
}
