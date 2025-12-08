import { Page } from "playwright"
import { UploadFileRequest } from "../contracts"

export async function uploadFile(page: Page, params: UploadFileRequest["params"]) {
  const files = params.files.map(file => ({
    name: file.name,
    mimeType: file.mimeType,
    buffer: Buffer.from(file.base64Data, "base64"),
  }))

  const fileChooser = await page.waitForEvent("filechooser")

  await fileChooser.setFiles(files)
}
