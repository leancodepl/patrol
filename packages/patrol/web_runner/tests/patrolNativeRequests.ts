import { Page } from "playwright";

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
type EnableDarkModeRequest = PatrolNativeRequestBase<
  "enableDarkMode",
  {
    appId?: string;
  }
>;
type DisableDarkModeRequest = PatrolNativeRequestBase<
  "disableDarkMode",
  {
    appId?: string;
  }
>;
type UnknownRequest = PatrolNativeRequestBase<
  `unkown-placeholder-${string}`,
  unknown
>;

type PatrolNativeRequest =
  | GrantPermissionsRequest
  | EnableDarkModeRequest
  | DisableDarkModeRequest
  | UnknownRequest;

export async function exposePatrolNativeRequestHandlers(
  page: Page,
  requestJson: string
) {
  try {
    const request: PatrolNativeRequest = JSON.parse(requestJson);
    const { action, params } = request;

    console.log(`[patrolNative] Action: ${action}`, params);

    switch (action) {
      case "grantPermissions": {
        const origin = params.origin ?? new URL(page.url()).origin;
        await page
          .context()
          .grantPermissions(params.permissions ?? [], { origin });
        console.log(
          `[patrolNative] Granted permissions: ${params.permissions?.join(
            ", "
          )} for ${origin}`
        );
        return JSON.stringify({ ok: true });
      }

      case "enableDarkMode":
        await page.emulateMedia({ colorScheme: "dark" });
        return JSON.stringify({ ok: true });

      case "disableDarkMode":
        await page.emulateMedia({ colorScheme: "no-preference" });
        return JSON.stringify({ ok: true });

      default:
        const error = `Unknown action: ${action}`;
        console.error(`[patrolNative] ${error}`);
        return JSON.stringify({ ok: false, error });
    }
  } catch (e) {
    const error = `Failed to execute: ${
      e instanceof Error ? e.message : String(e)
    }`;
    console.error(`[patrolNative]`, e);
    return JSON.stringify({ ok: false, error });
  }
}
