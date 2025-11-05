import { Page } from "playwright"
import { UploadFileRequest } from "../../contracts"
import { parseWebSelector } from "../../parseWebSelector"

export async function uploadFile(page: Page, params: UploadFileRequest["params"]) {
  const locator = parseWebSelector(page, params.selector)
  await locator.setInputFiles(params.filePaths)
}
