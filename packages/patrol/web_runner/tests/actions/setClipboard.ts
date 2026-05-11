import { ActionParams, SetClipboardRequest } from "../contracts"
import { logger } from "../logger"
import { sleep } from "../utils"

export async function setClipboard({ pageManager, params }: ActionParams<SetClipboardRequest>) {
  try {
    const write = async () => {
      await pageManager.activePage.evaluate(text => navigator.clipboard.writeText(text), params.text)
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
