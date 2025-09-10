import { chromium, type FullConfig } from "@playwright/test";
import fs from "fs/promises";
import path from "path";
import { PatrolTestEntry } from "./types";

async function globalSetup(config: FullConfig) {
  const { baseURL } = config.projects[0].use;
  const browser = await chromium.launch();
  const page = await browser.newPage();

  if (!baseURL) {
    throw new Error("baseURL is not set");
  }

  await page.goto(baseURL);

  await page.waitForFunction(
    () => typeof window.__patrol_listDartTests === "function",
    { timeout: 120000 }
  );

  const { group: testEntries } = await page.evaluate<{ group: DartTestEntry }>(
    () => JSON.parse(window.__patrol_listDartTests())
  );

  function mapEntry(
    entry: DartTestEntry,
    parentName?: string,
    skip = false,
    tags = new Set<string>()
  ) {
    const fullEntryName = parentName
      ? `${parentName} ${entry.name}`
      : entry.name;
    const fullEntrySkip = skip || entry.skip;
    const fullEntryTags = new Set([...tags, ...entry.tags]);

    const tests: PatrolTestEntry[] = [];

    if (entry.type === "test") {
      tests.push({
        name: fullEntryName,
        skip: fullEntrySkip,
        tags: [...fullEntryTags],
      });
    }

    tests.push(
      ...entry.entries.flatMap((e) =>
        mapEntry(e, fullEntryName, fullEntrySkip, fullEntryTags)
      )
    );

    return tests;
  }

  const tests = mapEntry(testEntries);

  await fs.writeFile(
    path.join(__dirname, "tests.json"),
    JSON.stringify(tests, null, 2)
  );

  await browser.close();
}

export default globalSetup;

type DartTestEntry = {
  type: "test" | "group";
  name: string;
  entries: DartTestEntry[];
  skip: boolean;
  tags: string[];
};
