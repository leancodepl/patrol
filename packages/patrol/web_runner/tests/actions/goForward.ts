import type { ActionParams, GoForwardRequest } from "../contracts"

export async function goForward({ pageManager }: ActionParams<GoForwardRequest>) {
  await pageManager.activePage.goForward()
}
