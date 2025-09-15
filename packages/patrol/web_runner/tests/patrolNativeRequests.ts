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
type UnknownRequest = PatrolNativeRequestBase<
  `unkown-placeholder-${string}`,
  unknown
>;

type PatrolNativeRequest = GrantPermissionsRequest | UnknownRequest;

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
