import { acceptNextDialog } from "./actions/acceptNextDialog"
import { addCookie } from "./actions/addCookie"
import { clearCookies } from "./actions/clearCookies"
import { clearPermissions } from "./actions/clearPermissions"
import { closeTab } from "./actions/closeTab"
import { disableDarkMode } from "./actions/disableDarkMode"
import { dismissNextDialog } from "./actions/dismissNextDialog"
import { enableDarkMode } from "./actions/enableDarkMode"
import { enterText } from "./actions/enterText"
import { getClipboard } from "./actions/getClipboard"
import { getCookies } from "./actions/getCookies"
import { getCurrentTab } from "./actions/getCurrentTab"
import { getTabs } from "./actions/getTabs"
import { goBack } from "./actions/goBack"
import { goForward } from "./actions/goForward"
import { grantPermissions } from "./actions/grantPermissions"
import { openNewTab } from "./actions/openNewTab"
import { pressKey } from "./actions/pressKey"
import { pressKeyCombo } from "./actions/pressKeyCombo"
import { resizeWindow } from "./actions/resizeWindow"
import { scrollTo } from "./actions/scrollTo"
import { setClipboard } from "./actions/setClipboard"
import { startTest } from "./actions/startTest"
import { switchToTab } from "./actions/switchToTab"
import { tap } from "./actions/tap"
import { uploadFile } from "./actions/uploadFile"
import { verifyFileDownloads } from "./actions/verifyFileDownloads"
import { waitForPopup } from "./actions/waitForPopup"

export const actions = {
  acceptNextDialog,
  addCookie,
  clearCookies,
  clearPermissions,
  closeTab,
  disableDarkMode,
  dismissNextDialog,
  enableDarkMode,
  enterText,
  getClipboard,
  getCookies,
  getCurrentTab,
  getTabs,
  goBack,
  goForward,
  grantPermissions,
  openNewTab,
  pressKey,
  pressKeyCombo,
  resizeWindow,
  scrollTo,
  setClipboard,
  startTest,
  switchToTab,
  tap,
  uploadFile,
  verifyFileDownloads,
  waitForPopup,
} as const
