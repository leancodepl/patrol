import { Page } from "playwright"
import { SetClipboardRequest } from "../contracts"
import { logger } from "../logger"
import { sleep } from "../utils"

export async function setClipboard(page: Page, params: SetClipboardRequest["params"]) {
  try {
    const write = async () => {
      await page.evaluate(text => navigator.clipboard.writeText(text), params.text)
      return true
    }

    const result = await Promise.race([write(), sleep(1)])

    if (!result) {
      throw new Error("Timeout")
    }
  } catch (error) {
    logger.error(error, "Clipboard is not available")
    throw error
  }
}
