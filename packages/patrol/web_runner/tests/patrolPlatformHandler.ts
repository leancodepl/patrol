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

export async function exposePatrolPlatformHandler(page: Page) {
  await page.exposeBinding(
    "__patrol__platformHandler",
    async ({ page }, request) => handlePatrolPlatformAction(page, request)
  );
}

async function handlePatrolPlatformAction(
  page: Page,
  { action, params }: PatrolNativeRequest
) {
  console.log(`Received action: ${action}`, params);

  try {
    switch (action) {
      case "grantPermissions": {
        const origin = params.origin ?? new URL(page.url()).origin;
        await page
          .context()
          .grantPermissions(params.permissions ?? [], { origin });
        console.log(
          `Granted permissions: ${params.permissions?.join(", ")} for ${origin}`
        );
        break;
      }

      case "enableDarkMode":
        await page.emulateMedia({ colorScheme: "dark" });
        break;

      case "disableDarkMode":
        await page.emulateMedia({ colorScheme: "no-preference" });
        break;

      default:
        console.error(`Unknown action received: ${action}`);
        throw new Error(`Unknown action received: ${action}`);
    }
  } catch (e) {
    console.error("Failed to handle patrol platform request", e);
    throw e;
  }
}
