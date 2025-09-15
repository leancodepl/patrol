import { chromium, Browser, Page, BrowserContext } from "playwright";
import { exposePatrolNativeRequestHandlers } from "./tests/patrolNativeRequests";

type PatrolTestResult = {
  result: "success" | "failure";
  details: string | null;
};

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
    console.log("💡 Press 'R' to restart the test execution (with fresh state)");
    console.log("💡 Press 'Ctrl+C' to exit");

    // Launch browser and create context once
    this.browser = await chromium.launch({ headless: false });
    this.context = await this.browser.newContext();
    this.page = await this.context.newPage();

    // Setup keyboard listener
    this.setupKeyboardListener();

    // Initial setup - expose bindings once
    await this.initialSetup();

    // Initial test run
    await this.runTest();

    // Keep the process alive
    await this.waitForever();
  }

  private async initialSetup() {
    if (!this.page) return;

    try {
      console.log("🔄 Loading test page...");
      
      // Navigate to the base URL
      await this.page.goto(this.baseUrl, { waitUntil: "load" });

      // Wait for the patrol test function to be available
      console.log("⏳ Waiting for __patrol_runDartTestWithCallback to be available...");
      await this.page.waitForFunction(
        () => {
          return typeof window.__patrol_runDartTestWithCallback === "function";
        },
        { timeout: 30000 }
      );

      // Expose the patrolNative binding (only once)
      await this.page.exposeBinding("patrolNative", async ({ page }, requestJson) =>
        exposePatrolNativeRequestHandlers(page, requestJson)
      );

      console.log("✅ Patrol bindings exposed successfully");

    } catch (error) {
      console.error("💥 Error during initial setup:", error);
      throw error;
    }
  }

  private async clearAppState() {
    if (!this.page || !this.context) return;

    try {
      console.log("🧹 Clearing app state...");

      // Clear all storage (localStorage, sessionStorage, indexedDB, etc.)
      await this.context.clearCookies();
      await this.page.evaluate(() => {
        // Clear localStorage
        localStorage.clear();
        // Clear sessionStorage
        sessionStorage.clear();
        // Clear indexedDB (if any)
        if (window.indexedDB) {
          // This is a more comprehensive way to clear indexedDB
          indexedDB.databases?.().then(databases => {
            databases.forEach(db => {
              if (db.name) {
                indexedDB.deleteDatabase(db.name);
              }
            });
          });
        }
      });

      // Reset permissions to default state
      await this.context.clearPermissions();

      // Clear cache
      await this.page.evaluate(() => {
        if ('caches' in window) {
          caches.keys().then(names => {
            names.forEach(name => {
              caches.delete(name);
            });
          });
        }
      });

      console.log("✅ App state cleared successfully");

    } catch (error) {
      console.error("💥 Error clearing app state:", error);
    }
  }

  private async runTest() {
    if (!this.page) return;

    try {
      // Execute the test with empty string as name (develop mode)
      console.log("🧪 Starting test execution in develop mode...");
      const testResult = await this.page.evaluate<PatrolTestResult, string>(
        (name) =>
          new Promise((resolve) => {
            window.__patrol_runDartTestWithCallback(name, (result) => {
              resolve(JSON.parse(result));
            });
          }),
        "example_test grant geolocation permission" // Empty string as test name for develop mode
      );

      if (testResult.result === "success") {
        console.log("✅ Test completed successfully");
      } else {
        console.log("❌ Test failed:", testResult.details || "No details available");
      }

    } catch (error) {
      console.error("💥 Error during test execution:", error);
    }
  }

  private setupKeyboardListener() {
    // Setup stdin to listen for keypresses
    if (process.stdin.isTTY) {
      process.stdin.setRawMode(true);
      process.stdin.resume();
      process.stdin.setEncoding('utf8');

      process.stdin.on('data', async (key) => {
        const keyStr = key.toString();
        
        // Handle 'R' or 'r' key press
        if (keyStr.toLowerCase() === 'r') {
          console.log("\n🔄 Restarting test execution with fresh state...");
          
          // Clear app state first
          await this.clearAppState();
          
          // Reload the page to restart the Flutter app
          await this.page!.reload({ waitUntil: "load" });
          
          // Wait for the patrol test function to be available again
          await this.page!.waitForFunction(
            () => {
              return typeof window.__patrol_runDartTestWithCallback === "function";
            },
            { timeout: 30000 }
          );
          
          // Run the test
          await this.runTest();
        }
        
        // Handle Ctrl+C
        if (keyStr === '\u0003') {
          console.log("\n👋 Exiting Patrol Develop mode...");
          await this.cleanup();
          process.exit(0);
        }
      });
    }
  }

  private async waitForever(): Promise<void> {
    return new Promise(() => {
      // This promise never resolves, keeping the process alive
      console.log("🎯 Develop mode is running. Waiting for interactions...");
    });
  }

  private async cleanup() {
    if (this.context) {
      await this.context.close();
    }
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Handle process termination
process.on('SIGINT', async () => {
  console.log("\n👋 Received SIGINT, cleaning up...");
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log("\n👋 Received SIGTERM, cleaning up...");
  process.exit(0);
});

// Start the develop mode
const patrolDevelop = new PatrolDevelop();
patrolDevelop.start().catch((error) => {
  console.error("💥 Failed to start Patrol Develop:", error);
  process.exit(1);
});
