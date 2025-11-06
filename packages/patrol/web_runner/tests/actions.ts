import { acceptDialog } from "./actions/acceptDialog"
import { addCookie } from "./actions/addCookie"
import { clearCookies } from "./actions/clearCookies"
import { clearPermissions } from "./actions/clearPermissions"
import { disableDarkMode } from "./actions/disableDarkMode"
import { dismissDialog } from "./actions/dismissDialog"
import { enableDarkMode } from "./actions/enableDarkMode"
import { enterText } from "./actions/enterText"
import { getClipboard } from "./actions/getClipboard"
import { getCookies } from "./actions/getCookies"
import { getDialogMessage } from "./actions/getDialogMessage"
import { goBack } from "./actions/goBack"
import { goForward } from "./actions/goForward"
import { grantPermissions } from "./actions/grantPermissions"
import { pressKey } from "./actions/pressKey"
import { pressKeyCombo } from "./actions/pressKeyCombo"
import { resizeWindow } from "./actions/resizeWindow"
import { scrollTo } from "./actions/scrollTo"
import { setClipboard } from "./actions/setClipboard"
import { tap } from "./actions/tap"
import { waitForDownload } from "./actions/todo/waitForDownload"
import { uploadFile } from "./actions/uploadFile"

export const actions = {
  grantPermissions,
  enableDarkMode,
  disableDarkMode,
  tap,
  enterText,
  scrollTo,
  clearPermissions,
  addCookie,
  getCookies,
  clearCookies,
  uploadFile,
  acceptDialog,
  dismissDialog,
  getDialogMessage,
  pressKey,
  pressKeyCombo,
  waitForDownload,
  goBack,
  goForward,
  getClipboard,
  setClipboard,
  resizeWindow,
} as const
