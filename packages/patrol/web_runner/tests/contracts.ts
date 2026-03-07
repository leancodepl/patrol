type PatrolNativeRequestBase<TAction extends string, TParams> = {
  action: TAction
  params: TParams & { _routeToTab?: string }
}

export type WebSelector = {
  role: string | null
  label: string | null
  placeholder: string | null
  text: string | null
  altText: string | null
  title: string | null
  testId: string | null
  cssOrXpath: string | null
}

export type GrantPermissionsRequest = PatrolNativeRequestBase<
  "grantPermissions",
  {
    permissions?: string[]
    origin?: string
  }
>

export type StartTestRequest = PatrolNativeRequestBase<"startTest", {}>
export type EnableDarkModeRequest = PatrolNativeRequestBase<"enableDarkMode", {}>
export type DisableDarkModeRequest = PatrolNativeRequestBase<"disableDarkMode", {}>
export type TapRequest = PatrolNativeRequestBase<
  "tap",
  {
    selector: WebSelector
    iframeSelector: WebSelector | null
  }
>
export type EnterTextRequest = PatrolNativeRequestBase<
  "enterText",
  {
    selector: WebSelector
    text: string
    iframeSelector: WebSelector | null
  }
>
export type ScrollToRequest = PatrolNativeRequestBase<
  "scrollTo",
  {
    selector: WebSelector
    iframeSelector: WebSelector | null
  }
>
export type ClearPermissionsRequest = PatrolNativeRequestBase<"clearPermissions", {}>
export type AddCookieRequest = PatrolNativeRequestBase<
  "addCookie",
  {
    name: string
    value: string
    url: string | null
    domain: string | null
    path: string | null
    expires: number | null
    httpOnly: boolean | null
    secure: boolean | null
    sameSite: "Lax" | "None" | "Strict" | null
  }
>
export type GetCookiesRequest = PatrolNativeRequestBase<"getCookies", {}>
export type ClearCookiesRequest = PatrolNativeRequestBase<"clearCookies", {}>
export type UploadFileRequest = PatrolNativeRequestBase<
  "uploadFile",
  {
    files: Array<{
      name: string
      mimeType: string
      base64Data: string
    }>
  }
>
export type AcceptNextDialogRequest = PatrolNativeRequestBase<"acceptNextDialog", {}>
export type DismissNextDialogRequest = PatrolNativeRequestBase<"dismissNextDialog", {}>
export type PressKeyRequest = PatrolNativeRequestBase<
  "pressKey",
  {
    key: string
  }
>
export type PressKeyComboRequest = PatrolNativeRequestBase<
  "pressKeyCombo",
  {
    keys: string[]
  }
>
export type VerifyFileDownloadsRequest = PatrolNativeRequestBase<"verifyFileDownloads", {}>
export type GoBackRequest = PatrolNativeRequestBase<"goBack", {}>
export type GoForwardRequest = PatrolNativeRequestBase<"goForward", {}>
export type GetClipboardRequest = PatrolNativeRequestBase<"getClipboard", {}>
export type SetClipboardRequest = PatrolNativeRequestBase<
  "setClipboard",
  {
    text: string
  }
>
export type ResizeWindowRequest = PatrolNativeRequestBase<
  "resizeWindow",
  {
    width: number
    height: number
  }
>
export type OpenNewTabRequest = PatrolNativeRequestBase<
  "openNewTab",
  {
    url: string
  }
>
export type CloseTabRequest = PatrolNativeRequestBase<
  "closeTab",
  {
    tabId: string
  }
>
export type SwitchToTabRequest = PatrolNativeRequestBase<
  "switchToTab",
  {
    tabId: string
  }
>
export type GetTabsRequest = PatrolNativeRequestBase<"getTabs", {}>
export type GetCurrentTabRequest = PatrolNativeRequestBase<"getCurrentTab", {}>
export type WaitForPopupRequest = PatrolNativeRequestBase<
  "waitForPopup",
  {
    triggerAction: string
    triggerParams: Record<string, unknown>
  }
>
type UnknownRequest = PatrolNativeRequestBase<`unknown-placeholder-${string}`, unknown>

export type PatrolNativeRequest =
  | AcceptNextDialogRequest
  | AddCookieRequest
  | ClearCookiesRequest
  | ClearPermissionsRequest
  | CloseTabRequest
  | DisableDarkModeRequest
  | DismissNextDialogRequest
  | EnableDarkModeRequest
  | EnterTextRequest
  | GetClipboardRequest
  | GetCookiesRequest
  | GetCurrentTabRequest
  | GetTabsRequest
  | GoBackRequest
  | GoForwardRequest
  | GrantPermissionsRequest
  | OpenNewTabRequest
  | PressKeyComboRequest
  | PressKeyRequest
  | ResizeWindowRequest
  | ScrollToRequest
  | SetClipboardRequest
  | StartTestRequest
  | SwitchToTabRequest
  | TapRequest
  | UnknownRequest
  | UploadFileRequest
  | VerifyFileDownloadsRequest
  | WaitForPopupRequest
