import type { ActionParams, ClearPermissionsRequest } from "../contracts"

export async function clearPermissions({ pageManager }: ActionParams<ClearPermissionsRequest>) {
  await pageManager.context.clearPermissions()
}
