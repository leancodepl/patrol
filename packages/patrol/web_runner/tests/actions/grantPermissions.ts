import { Page } from "playwright";
import { GrantPermissionsRequest } from "../contracts";

export async function grantPermissions(
  page: Page,
  params: GrantPermissionsRequest["params"]
) {
  const origin = params.origin ?? new URL(page.url()).origin;
  await page.context().grantPermissions(params.permissions ?? [], { origin });
  console.log(
    `Granted permissions: ${params.permissions?.join(", ")} for ${origin}`
  );
}
