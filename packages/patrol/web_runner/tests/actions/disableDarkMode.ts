import { Page } from "playwright";

export async function disableDarkMode(page: Page) {
  await page.emulateMedia({ colorScheme: "no-preference" });
  console.log("Dark mode disabled");
}
