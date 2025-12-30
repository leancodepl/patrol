import { Page } from "playwright"
import { GrantPermissionsRequest } from "../contracts"
import { logger } from "../logger"

export async function grantPermissions(page: Page, params: GrantPermissionsRequest["params"]) {
  const origin = params.origin ?? new URL(page.url()).origin
  await page.context().grantPermissions(params.permissions ?? [], { origin })
  logger.info(`Granted permissions: ${params.permissions?.join(", ")} for ${origin}`)
}
