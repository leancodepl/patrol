import type { ActionParams, GrantPermissionsRequest } from "../contracts"
import { logger } from "../logger"

export async function grantPermissions({ pageManager, params }: ActionParams<GrantPermissionsRequest>) {
  const origin = params.origin ?? new URL(pageManager.activePage.url()).origin
  await pageManager.context.grantPermissions(params.permissions ?? [], { origin })
  logger.info(`Granted permissions: ${params.permissions?.join(", ")} for ${origin}`)
}
