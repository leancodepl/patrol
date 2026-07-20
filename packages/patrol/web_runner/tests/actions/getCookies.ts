import type { ActionParams, GetCookiesRequest } from "../contracts"

export async function getCookies({ pageManager }: ActionParams<GetCookiesRequest>) {
  return await pageManager.context.cookies()
}
