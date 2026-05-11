import { acceptNextDialog } from "./actions/acceptNextDialog"
import { addCookie } from "./actions/addCookie"
import { clearCookies } from "./actions/clearCookies"
import { clearPermissions } from "./actions/clearPermissions"
import { closePage } from "./actions/closePage"
import { disableDarkMode } from "./actions/disableDarkMode"
import { dismissNextDialog } from "./actions/dismissNextDialog"
import { enableDarkMode } from "./actions/enableDarkMode"
import { enterText } from "./actions/enterText"
import { getClipboard } from "./actions/getClipboard"
import { getCookies } from "./actions/getCookies"
import { getCurrentPage } from "./actions/getCurrentPage"
import { getPages } from "./actions/getPages"
import { goBack } from "./actions/goBack"
import { goForward } from "./actions/goForward"
import { grantPermissions } from "./actions/grantPermissions"
import { openNewPage } from "./actions/openNewPage"
import { pressKey } from "./actions/pressKey"
import { pressKeyCombo } from "./actions/pressKeyCombo"
import { resizeWindow } from "./actions/resizeWindow"
import { scrollTo } from "./actions/scrollTo"
import { setClipboard } from "./actions/setClipboard"
import { startTest } from "./actions/startTest"
import { switchToPage } from "./actions/switchToPage"
import { tap } from "./actions/tap"
import { uploadFile } from "./actions/uploadFile"
import { verifyFileDownloads } from "./actions/verifyFileDownloads"
import { waitForPopup } from "./actions/waitForPopup"
import { ActionParams, PatrolNativeRequest } from "./contracts"

export const actions = {
  acceptNextDialog,
  addCookie,
  clearCookies,
  clearPermissions,
  closePage,
  disableDarkMode,
  dismissNextDialog,
  enableDarkMode,
  enterText,
  getClipboard,
  getCookies,
  getCurrentPage,
  getPages,
  goBack,
  goForward,
  grantPermissions,
  openNewPage,
  pressKey,
  pressKeyCombo,
  resizeWindow,
  scrollTo,
  setClipboard,
  startTest,
  switchToPage,
  tap,
  uploadFile,
  verifyFileDownloads,
  waitForPopup,
} as const satisfies Record<string, (params: ActionParams<any>) => Promise<any>>
