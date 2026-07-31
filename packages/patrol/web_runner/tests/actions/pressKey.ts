import { ActionParams, PressKeyRequest } from "../contracts"

export async function pressKey({ pageManager, params }: ActionParams<PressKeyRequest>) {
  await pageManager.activePage.keyboard.press(params.key)
}
