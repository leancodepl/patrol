import { ActionParams, UploadFileRequest } from "../contracts"

export async function uploadFile({ pageManager, params }: ActionParams<UploadFileRequest>) {
  const files = params.files.map(file => ({
    name: file.name,
    mimeType: file.mimeType,
    buffer: Buffer.from(file.base64Data, "base64"),
  }))

  const fileChooser = await pageManager.activePage.waitForEvent("filechooser")

  await fileChooser.setFiles(files)
}
