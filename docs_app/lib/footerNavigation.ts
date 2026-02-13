import { findNeighbour } from "fumadocs-core/page-tree"
import { source } from "./source"
import type * as PageTree from "fumadocs-core/page-tree"
import type { InferPageType } from "fumadocs-core/source"

type PageType = InferPageType<typeof source>

type FooterItem = Pick<PageTree.Item, "description" | "name" | "url">

type FooterNavigation = {
  previous?: FooterItem
  next?: FooterItem
}

export function getFooterNavigation(page: PageType): FooterNavigation {
  const autoFooter = findNeighbour(source.pageTree, page.url)

  return {
    previous: getPreviousNavigation(page, autoFooter),
    next: getNextNavigation(page, autoFooter),
  }
}

function getPreviousNavigation(page: PageType, autoFooter: ReturnType<typeof findNeighbour>): FooterItem | undefined {
  if (page.data.hidePrevious) {
    return undefined
  }

  if (page.data.previous || page.data.previousTitle) {
    return {
      name: page.data.previousTitle ?? autoFooter.previous?.name ?? "Previous",
      url: page.data.previous ?? autoFooter.previous?.url ?? "",
    }
  }

  return autoFooter.previous
}

function getNextNavigation(page: PageType, autoFooter: ReturnType<typeof findNeighbour>): FooterItem | undefined {
  if (page.data.hideNext) {
    return undefined
  }

  if (page.data.next || page.data.nextTitle) {
    return {
      name: page.data.nextTitle ?? autoFooter.next?.name ?? "Next",
      url: page.data.next ?? autoFooter.next?.url ?? "",
    }
  }

  return autoFooter.next
}
