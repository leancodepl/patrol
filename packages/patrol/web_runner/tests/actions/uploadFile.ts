import { ActionParams, UploadFileRequest } from "../contracts"

// Opening a browser file chooser requires a trusted user gesture. A Patrol/
// Flutter tap is a synthetic framework pointer event, not a trusted DOM gesture,
// so the app's file <input>.click() (triggered from Flutter) would be
// suppressed and no `filechooser` event would fire. Instead we:
//   (1) grant the page transient user activation via a real key press — this is
//       a window-global ~5s flag that a subsequent (synthetic-tap-triggered)
//       input.click() can consume, so the chooser is allowed to open; and
//   (2) arm a one-time chooser handler carrying the in-memory files.
// We return immediately (no blocking `waitForEvent`) so the Dart side can then
// perform the tap that opens the picker; the armed handler answers it.
export async function uploadFile({
  pageManager,
  params,
}: ActionParams<UploadFileRequest>) {
  const files = params.files.map(file => ({
    name: file.name,
    mimeType: file.mimeType,
    buffer: Buffer.from(file.base64Data, "base64"),
  }))

  const page = pageManager.activePage

  // (1) Grant transient user activation.
  await page.keyboard.press("Tab")

  // (2) Arm a one-time handler that supplies the files when the app opens the
  // chooser. Registered before this action returns, so it is listening before
  // the caller's tap triggers the picker.
  page.once("filechooser", async chooser => {
    await chooser.setFiles(files)
  })
}
