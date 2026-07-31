import type { ActionParams, ClearCookiesRequest } from "../contracts"

export async function clearCookies({ pageManager }: ActionParams<ClearCookiesRequest>) {
  await pageManager.context.clearCookies()
}
