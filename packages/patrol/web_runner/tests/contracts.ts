type PatrolNativeRequestBase<TAction extends string, TParams> = {
  action: TAction
  params: TParams
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
export type AcceptDialogRequest = PatrolNativeRequestBase<"acceptDialog", {}>
export type DismissDialogRequest = PatrolNativeRequestBase<"dismissDialog", {}>
export type GetDialogMessageRequest = PatrolNativeRequestBase<"getDialogMessage", {}>
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
export type WaitForDownloadRequest = PatrolNativeRequestBase<
  "waitForDownload",
  {
    timeoutMs?: number
  }
>
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
type UnknownRequest = PatrolNativeRequestBase<`unknown-placeholder-${string}`, unknown>

export type PatrolNativeRequest =
  | AcceptDialogRequest
  | AddCookieRequest
  | ClearCookiesRequest
  | ClearPermissionsRequest
  | DisableDarkModeRequest
  | DismissDialogRequest
  | EnableDarkModeRequest
  | EnterTextRequest
  | GetClipboardRequest
  | GetCookiesRequest
  | GetDialogMessageRequest
  | GoBackRequest
  | GoForwardRequest
  | GrantPermissionsRequest
  | PressKeyComboRequest
  | PressKeyRequest
  | ResizeWindowRequest
  | ScrollToRequest
  | SetClipboardRequest
  | TapRequest
  | UnknownRequest
  | UploadFileRequest
  | WaitForDownloadRequest
