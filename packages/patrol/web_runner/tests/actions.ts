import { addCookie } from "./actions/addCookie"
import { clearCookies } from "./actions/clearCookies"
import { clearPermissions } from "./actions/clearPermissions"
import { disableDarkMode } from "./actions/disableDarkMode"
import { enableDarkMode } from "./actions/enableDarkMode"
import { getClipboard } from "./actions/getClipboard"
import { getCookies } from "./actions/getCookies"
import { goBack } from "./actions/goBack"
import { goForward } from "./actions/goForward"
import { grantPermissions } from "./actions/grantPermissions"
import { setClipboard } from "./actions/setClipboard"
import { acceptDialog } from "./actions/todo/acceptDialog"
import { dismissDialog } from "./actions/todo/dismissDialog"
import { enterText } from "./actions/todo/enterText"
import { getDialogMessage } from "./actions/todo/getDialogMessage"
import { pressKey } from "./actions/todo/pressKey"
import { pressKeyCombo } from "./actions/todo/pressKeyCombo"
import { scrollTo } from "./actions/todo/scrollTo"
import { tap } from "./actions/todo/tap"
import { uploadFile } from "./actions/todo/uploadFile"
import { waitForDownload } from "./actions/todo/waitForDownload"

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
} as const
