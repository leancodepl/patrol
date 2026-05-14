import type { ActionParams, GoBackRequest } from "../contracts"

export async function goBack({ pageManager }: ActionParams<GoBackRequest>) {
  await pageManager.activePage.goBack()
}
