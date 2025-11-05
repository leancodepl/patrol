import { Page } from "playwright"
import { AddCookieRequest } from "../../contracts"

export async function addCookie(page: Page, params: AddCookieRequest["params"]) {
  await page.context().addCookies([
    {
      name: params.name,
      value: params.value,
      domain: params.domain,
      path: params.path,
      expires: params.expires,
      httpOnly: params.httpOnly,
      secure: params.secure,
      sameSite: params.sameSite,
    },
  ])
}
