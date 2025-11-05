import { clearPermissions } from "./actions/clearPermissions"
import { disableDarkMode } from "./actions/disableDarkMode"
import { enableDarkMode } from "./actions/enableDarkMode"
import { grantPermissions } from "./actions/grantPermissions"
import { acceptDialog } from "./actions/todo/acceptDialog"
import { addCookie } from "./actions/todo/addCookie"
import { clearCookies } from "./actions/todo/clearCookies"
import { dismissDialog } from "./actions/todo/dismissDialog"
import { enterText } from "./actions/todo/enterText"
import { getClipboard } from "./actions/todo/getClipboard"
import { getCookies } from "./actions/todo/getCookies"
import { getDialogMessage } from "./actions/todo/getDialogMessage"
import { goBack } from "./actions/todo/goBack"
import { goForward } from "./actions/todo/goForward"
import { pressKey } from "./actions/todo/pressKey"
import { pressKeyCombo } from "./actions/todo/pressKeyCombo"
import { scrollTo } from "./actions/todo/scrollTo"
import { setClipboard } from "./actions/todo/setClipboard"
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
    setClipboard
  } as const;