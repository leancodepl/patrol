import type { ActionParams, ResizeWindowRequest } from "../contracts"

export async function resizeWindow({ pageManager, params }: ActionParams<ResizeWindowRequest>) {
  await pageManager.activePage.setViewportSize({
    width: params.width,
    height: params.height,
  })
}
