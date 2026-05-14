import type { ActionParams, PressKeyComboRequest } from "../contracts"

export async function pressKeyCombo({ pageManager, params }: ActionParams<PressKeyComboRequest>) {
  const combo = params.keys.join("+")
  await pageManager.activePage.keyboard.press(combo)
}
