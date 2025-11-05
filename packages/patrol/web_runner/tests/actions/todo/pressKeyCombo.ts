import { Page } from "playwright"
import { PressKeyComboRequest } from "../../contracts"

export async function pressKeyCombo(page: Page, params: PressKeyComboRequest["params"]) {
  const combo = params.keys.join("+")
  await page.keyboard.press(combo)
}
