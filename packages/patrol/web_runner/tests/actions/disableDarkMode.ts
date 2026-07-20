import { logger } from "../logger"
import type { ActionParams, DisableDarkModeRequest } from "../contracts"

export async function disableDarkMode({ pageManager }: ActionParams<DisableDarkModeRequest>) {
  await pageManager.activePage.emulateMedia({ colorScheme: "light" })
  logger.info("Dark mode disabled")
}
