import { test as base } from "@playwright/test";
import { initialise } from "./initialise";
import { exposePatrolPlatformHandler } from "./patrolPlatformHandler";
import { PatrolTestEntry, PatrolTestResult } from "./types";

const tests: PatrolTestEntry[] = JSON.parse(process.env.PATROL_TESTS!);

export const patrolTest = base.extend({
  page: async ({ page }, use) => {
    await page.goto("/", { waitUntil: "load" });

    await exposePatrolPlatformHandler(page);

    await initialise(page);

    await use(page);
  },
});

for (const { name, skip, tags } of tests) {
  patrolTest(name, { tag: tags }, async ({ page }) => {
    patrolTest.skip(skip);

    await page.waitForFunction(() => window.__patrol__runTest, {
      timeout: 120000,
    });

    const testResult = await page.evaluate(
      async (name) => await window.__patrol__runTest!(name),
      name
    );

    patrolTest
      .expect(testResult.result, testResult.details ?? undefined)
      .toBe("success");
  });
}
