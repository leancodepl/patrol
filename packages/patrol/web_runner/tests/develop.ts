import { chromium } from "playwright"
import { initialise } from "./initialise"
import { logger } from "./logger"
import { exposePatrolPlatformHandler } from "./patrolPlatformHandler"
import "./types"

process.on("SIGINT", () => {
  logger.info("\nReceived SIGINT (Ctrl+C). Shutting down gracefully...")
  process.exit(0)
})

async function develop() {
  try {
    const browser = await chromium.connectOverCDP(`http://localhost:${process.env.DEBUGGER_PORT}`)

    const context = browser.contexts().at(0) ?? (await browser.newContext())

    const page = context.pages().at(0) ?? (await context.newPage())

    await exposePatrolPlatformHandler(page)

    await initialise(page)

    setInterval(() => {}, 30000)
  } catch (error) {
    console.error("Error in develop function:", error)
  }
}

develop()
