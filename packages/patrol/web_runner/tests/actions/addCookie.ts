import { Page } from "playwright"
import { AddCookieRequest } from "../contracts"
import { logger } from "../logger"

export async function addCookie(page: Page, params: AddCookieRequest["params"]) {
  logger.info(`Adding cookie: ${params.name} = ${params.value}`)
  logger.info(`Domain: ${params.domain}`)
  await page.context().addCookies([
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
