import type { Page, BrowserContext } from "playwright"

export class PageManager {
  private registry = new Map<string, Page>()
  private reverse = new Map<Page, string>()
  private _activeId: string
  readonly mainPageId: string
  private nextIndex = 0

  constructor(
    readonly context: BrowserContext,
    mainPage: Page,
  ) {
    this.context = context
    this.mainPageId = this.register(mainPage)
    this._activeId = this.mainPageId

    this.context.on("page", (page: Page) => {
      this.register(page)
    })
  }

  private register(page: Page): string {
    const id = `page_${this.nextIndex++}`

    this.registry.set(id, page)
    this.reverse.set(page, id)

    const cleanup = () => {
      this.registry.delete(id)
      this.reverse.delete(page)
      if (this._activeId === id) {
        this._activeId = this.mainPageId
      }
    }

    page.on("close", cleanup)
    page.on("crash", cleanup)

    return id
  }

  resolve(pageId: string): Page {
    const page = this.registry.get(pageId)

    if (!page) {
      throw new Error(`No page found for page ID "${pageId}"`)
    }

    return page
  }

  get activePage(): Page {
    return this.resolve(this._activeId)
  }

  get activeId(): string {
    return this._activeId
  }

  set activeId(pageId: string) {
    if (!this.registry.has(pageId)) {
      throw new Error(`No page found for page ID "${pageId}"`)
    }

    this._activeId = pageId
  }

  get count(): number {
    return this.registry.size
  }

  get ids(): string[] {
    return Array.from(this.registry.keys())
  }

  idOf(page: Page): string | undefined {
    return this.reverse.get(page)
  }

  isMainPage(page: Page): boolean {
    const pageId = this.reverse.get(page)
    return !!pageId && this.isMainPageId(pageId)
  }

  isMainPageId(pageId: string): boolean {
    return pageId === this.mainPageId
  }
}
