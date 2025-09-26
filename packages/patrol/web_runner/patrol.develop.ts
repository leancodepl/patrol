import { chromium, Browser, Page, BrowserContext } from "playwright";
import { exposePatrolNativeRequestHandlers } from "./tests/patrolNativeRequests";

class PatrolDevelop {
  private browser: Browser | null = null;
  private context: BrowserContext | null = null;
  private page: Page | null = null;
  private baseUrl: string;

  constructor() {
    this.baseUrl = process.env.BASE_URL || "http://localhost:3000";
  }

  async start() {
    console.log("🚀 Starting Patrol Develop mode...");
    console.log(`📍 Base URL: ${this.baseUrl}`);
    console.log(
      "💡 Press 'R' to restart the test execution (with fresh state)"
    );
    console.log("💡 Press 'Ctrl+C' to exit");

    // Launch browser and create context once
    this.browser = await chromium.connectOverCDP("http://localhost:37497");
    this.context =
      this.browser.contexts().at(0) ?? (await this.browser.newContext());
    this.page = this.context.pages().at(0) ?? (await this.context.newPage());

    this.page.goto("http://onet.pl");
  }
}

// Start the develop mode
const patrolDevelop = new PatrolDevelop();
patrolDevelop.start().catch((error) => {
  console.error("💥 Failed to start Patrol Develop:", error);
  process.exit(1);
});
