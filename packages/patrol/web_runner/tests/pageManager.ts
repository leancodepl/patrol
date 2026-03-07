import type { Page, BrowserContext } from "playwright"

export class PageManager {
  private _registry = new Map<string, Page>()
  private _reverse = new Map<Page, string>()
  private _activeId: string
  private _nextIndex = 0
  readonly context: BrowserContext

  constructor(context: BrowserContext, initialPage: Page) {
    this.context = context
    this._register(initialPage)
    this._activeId = "tab_0"

    context.on("page", (page: Page) => {
      this._register(page)
    })
  }

  private _register(page: Page): string {
    const id = `tab_${this._nextIndex++}`
    this._registry.set(id, page)
    this._reverse.set(page, id)

    const cleanup = () => {
      this._registry.delete(id)
      this._reverse.delete(page)
      if (this._activeId === id) {
        this._activeId = "tab_0"
      }
    }

    page.on("close", cleanup)
    page.on("crash", cleanup)

    return id
  }

  resolve(tabId?: string): Page {
    const id = tabId ?? this._activeId
    const page = this._registry.get(id)
    if (!page) {
      throw new Error(`No page found for tab ID "${id}"`)
    }
    return page
  }

  get activeId(): string {
    return this._activeId
  }

  set activeId(tabId: string) {
    if (!this._registry.has(tabId)) {
      throw new Error(`No page found for tab ID "${tabId}"`)
    }
    this._activeId = tabId
  }

  get count(): number {
    return this._registry.size
  }

  get ids(): string[] {
    return Array.from(this._registry.keys())
  }

  idOf(page: Page): string | undefined {
    return this._reverse.get(page)
  }
}
