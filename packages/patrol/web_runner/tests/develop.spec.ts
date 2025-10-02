import { chromium } from "playwright";
import { exposePatrolNativeRequestHandlers } from "./patrolNativeRequests";
import "./types";

async function develop() {
  const browser = await chromium.connectOverCDP(
    `http://localhost:${process.env.DEBUGGER_PORT}`
  );

  const context = browser.contexts().at(0) ?? (await browser.newContext());

  const page = context.pages().at(0) ?? (await context.newPage());

  await page.exposeBinding("patrolNative", async ({ page }, requestJson) =>
    exposePatrolNativeRequestHandlers(page, requestJson)
  );

  await page.waitForFunction(
    () => {
      if (typeof window.__patrol_setInitialised !== "function") return false;

      window.__patrol_setInitialised();

      return true;
    },
    { timeout: 60000 }
  );
}

process.on("SIGINT", () => {
  console.log("\nReceived SIGINT (Ctrl+C). Shutting down gracefully...");
  process.exit(0);
});

async function runIndefinitely() {
  try {
    await develop();

    setInterval(() => {}, 30000);
  } catch (error) {
    console.error("Error in develop function:", error);
  }
}

runIndefinitely();
