import { test } from "@playwright/test";
import fs from "fs";
import path from "path";
import { PatrolTestEntry } from "./types";
import { exposePatrolNativeRequestHandlers } from "./patrolNativeRequests";

const tests: PatrolTestEntry[] = JSON.parse(
  fs.readFileSync(path.join(__dirname, "tests.json"), "utf-8")
);

test.beforeEach(async ({ page }) => {
  await page.goto("/", { waitUntil: "load" });

  await page.waitForFunction(
    () => {
      return typeof window.__patrol_runDartTestWithCallback === "function";
    },
    { timeout: 30000 }
  );

  await page.exposeBinding("patrolNative", async ({ page }, requestJson) =>
    exposePatrolNativeRequestHandlers(page, requestJson)
  );
});

for (const { name, skip, tags } of tests) {
  test(name, { tag: tags }, async ({ page }) => {
    test.skip(skip);

    const testResult = await page.evaluate<PatrolTestResult, string>(
      (name) =>
        new Promise((resolve) => {
          window.__patrol_runDartTestWithCallback(name, (result) => {
            resolve(JSON.parse(result));
          });
        }),
      name
    );

    test
      .expect(testResult.result, testResult.details ?? undefined)
      .toBe("success");
  });
}

type PatrolTestResult = {
  result: "success" | "failure";
  details: string | null;
};
