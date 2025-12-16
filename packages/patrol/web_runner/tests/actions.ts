import { acceptNextDialog } from "./actions/acceptNextDialog"
import { addCookie } from "./actions/addCookie"
import { clearCookies } from "./actions/clearCookies"
import { clearPermissions } from "./actions/clearPermissions"
import { disableDarkMode } from "./actions/disableDarkMode"
import { dismissNextDialog } from "./actions/dismissNextDialog"
import { enableDarkMode } from "./actions/enableDarkMode"
import { enterText } from "./actions/enterText"
import { getClipboard } from "./actions/getClipboard"
import { getCookies } from "./actions/getCookies"
import { goBack } from "./actions/goBack"
import { goForward } from "./actions/goForward"
import { grantPermissions } from "./actions/grantPermissions"
import { pressKey } from "./actions/pressKey"
import { pressKeyCombo } from "./actions/pressKeyCombo"
import { resizeWindow } from "./actions/resizeWindow"
import { scrollTo } from "./actions/scrollTo"
import { setClipboard } from "./actions/setClipboard"
import { startTest } from "./actions/startTest"
import { tap } from "./actions/tap"
import { uploadFile } from "./actions/uploadFile"
import { verifyFileDownloads } from "./actions/verifyFileDownloads"

export const actions = {
  startTest,
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
  acceptNextDialog,
  dismissNextDialog,
  pressKey,
  pressKeyCombo,
  verifyFileDownloads,
  goBack,
  goForward,
  getClipboard,
  setClipboard,
  resizeWindow,
} as const
