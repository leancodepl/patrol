type PatrolNativeRequestBase<TAction extends string, TParams> = {
  action: TAction;
  params: TParams;
};

type GrantPermissionsRequest = PatrolNativeRequestBase<
  "grantPermissions",
  {
    permissions?: string[];
    origin?: string;
  }
>;
type EnableDarkModeRequest = PatrolNativeRequestBase<"enableDarkMode", {}>;
type DisableDarkModeRequest = PatrolNativeRequestBase<"disableDarkMode", {}>;
type UnknownRequest = PatrolNativeRequestBase<
  `unknown-placeholder-${string}`,
  unknown
>;

type PatrolNativeRequest =
  | GrantPermissionsRequest
  | EnableDarkModeRequest
  | DisableDarkModeRequest
  | UnknownRequest;
