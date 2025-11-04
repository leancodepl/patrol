import { Page } from "playwright";

export async function enableDarkMode(page: Page) {
  await page.emulateMedia({ colorScheme: "dark" });
  console.log("Dark mode enabled");
}
