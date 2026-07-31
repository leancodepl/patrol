import { logger } from "../logger"
import type { ActionParams, EnableDarkModeRequest } from "../contracts"

export async function enableDarkMode({ pageManager }: ActionParams<EnableDarkModeRequest>) {
  await pageManager.activePage.emulateMedia({ colorScheme: "dark" })
  logger.info("Dark mode enabled")
}
