import type { ActionParams, AddCookieRequest } from "../contracts"
import { logger } from "../logger"

export async function addCookie({ pageManager, params }: ActionParams<AddCookieRequest>) {
  logger.info(`Adding cookie: ${params.name} = ${params.value}`)
  logger.info(`Domain: ${params.domain}`)
  await pageManager.context.addCookies([
    {
      name: params.name,
      value: params.value,
      url: params.url ?? undefined,
      domain: params.domain ?? undefined,
      path: params.path ?? undefined,
      expires: params.expires ?? undefined,
      httpOnly: params.httpOnly ?? undefined,
      secure: params.secure ?? undefined,
      sameSite: params.sameSite ?? undefined,
    },
  ])
}
