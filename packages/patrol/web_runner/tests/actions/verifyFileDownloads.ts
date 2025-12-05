import { logger } from "../logger"
import { downloadedFiles } from "./startTest"

export async function verifyFileDownloads() {
  logger.info(`Current downloads: ${JSON.stringify(downloadedFiles)}`)
  return downloadedFiles
}
