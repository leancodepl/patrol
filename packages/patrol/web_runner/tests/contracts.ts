type PatrolNativeRequestBase<TAction extends string, TParams> = {
  action: TAction;
  params: TParams;
};

export type GrantPermissionsRequest = PatrolNativeRequestBase<
  "grantPermissions",
  {
    permissions?: string[];
    origin?: string;
  }
>;
export type EnableDarkModeRequest = PatrolNativeRequestBase<
  "enableDarkMode",
  {}
>;
export type DisableDarkModeRequest = PatrolNativeRequestBase<
  "disableDarkMode",
  {}
>;
type UnknownRequest = PatrolNativeRequestBase<
  `unknown-placeholder-${string}`,
  unknown
>;

export type PatrolNativeRequest =
  | GrantPermissionsRequest
  | EnableDarkModeRequest
  | DisableDarkModeRequest
  | UnknownRequest;
