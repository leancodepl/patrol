import { Page } from "playwright"
import { ResizeWindowRequest } from "../contracts"

export async function resizeWindow(page: Page, params: ResizeWindowRequest["params"]) {
  await page.setViewportSize({
    width: params.width,
    height: params.height,
  })
}
