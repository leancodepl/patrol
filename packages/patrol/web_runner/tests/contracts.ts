type PatrolNativeRequestBase<TAction extends string, TParams> = {
  action: TAction
  params: TParams
}

export type WebSelector = {
  role?: string
  label?: string
  placeholder?: string
  text?: string
  altText?: string
  title?: string
  testId?: string
  cssOrXpath?: string
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
export type TapRequest = PatrolNativeRequestBase<"tap", WebSelector>
export type EnterTextRequest = PatrolNativeRequestBase<
  "enterText",
  {
    selector: WebSelector
    text: string
  }
>
export type ScrollToRequest = PatrolNativeRequestBase<"scrollTo", WebSelector>
export type ClearPermissionsRequest = PatrolNativeRequestBase<"clearPermissions", {}>
export type AddCookieRequest = PatrolNativeRequestBase<
  "addCookie",
  {
    name: string
    value: string
    domain?: string
    path?: string
    expires?: number
    httpOnly?: boolean
    secure?: boolean
    sameSite?: "Lax" | "None" | "Strict"
  }
>
export type GetCookiesRequest = PatrolNativeRequestBase<"getCookies", {}>
export type ClearCookiesRequest = PatrolNativeRequestBase<"clearCookies", {}>
export type UploadFileRequest = PatrolNativeRequestBase<
  "uploadFile",
  {
    selector: WebSelector
    filePaths: string[]
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
  | ScrollToRequest
  | SetClipboardRequest
  | TapRequest
  | UnknownRequest
  | UploadFileRequest
  | WaitForDownloadRequest
