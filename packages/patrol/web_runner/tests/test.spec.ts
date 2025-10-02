import fs from "fs";
import path from "path";
import { PatrolTestEntry, PatrolTestResult } from "./types";
import { test as base } from "@playwright/test";
import { exposePatrolNativeRequestHandlers } from "./patrolNativeRequests";

const tests: PatrolTestEntry[] = JSON.parse(
  fs.readFileSync(path.join(__dirname, "tests.json"), "utf-8")
);

export const patrolTest = base.extend({
  page: async ({ page }, use) => {
    await page.goto("/", { waitUntil: "load" });

    await page.exposeBinding("patrolNative", async ({ page }, requestJson) =>
      exposePatrolNativeRequestHandlers(page, requestJson)
    );

    await page.waitForFunction(
      () => {
        return typeof window.__patrol_runDartTestWithCallback === "function";
      },
      { timeout: 60000 }
    );

    await use(page);
  },
});

for (const { name, skip, tags } of tests) {
  patrolTest(name, { tag: tags }, async ({ page }) => {
    patrolTest.skip(skip);

    console.log("Running test: ", name);

    const testResult = await page.evaluate<PatrolTestResult, string>(
      (name) =>
        new Promise((resolve) => {
          window.__patrol_runDartTestWithCallback(name, (result) => {
            resolve(JSON.parse(result));
          });
        }),
      name
    );

    console.log("Test result: ", testResult);

    patrolTest
      .expect(testResult.result, testResult.details ?? undefined)
      .toBe("success");
  });
}
