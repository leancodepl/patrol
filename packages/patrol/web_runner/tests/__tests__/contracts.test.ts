import { test, expect } from "@playwright/test"
import type {
  TapRequest,
  OpenNewPageRequest,
  ClosePageRequest,
  SwitchToPageRequest,
  GetPagesRequest,
  GetCurrentPageRequest,
  WaitForPopupRequest,
  PatrolNativeRequest,
} from "../contracts"

// ---------------------------------------------------------------------------
// Type-level helpers -- these are compile-time-only checks.
// If a type does not satisfy the constraint the file will not compile.
// ---------------------------------------------------------------------------

// Asserts that type A is assignable to type B.
type AssertAssignable<A, B extends A> = B

// ---------------------------------------------------------------------------
// 1. Existing requests still work 
// ---------------------------------------------------------------------------

type _TapWithoutPageId = AssertAssignable<
  TapRequest,
  {
    action: "tap"
    params: {
      selector: {
        role: null
        label: null
        placeholder: null
        text: null
        altText: null
        title: null
        testId: null
        cssOrXpath: null
      }
      iframeSelector: null
    }
  }
>


// ---------------------------------------------------------------------------
// 2. New request types exist and have the correct shape
// ---------------------------------------------------------------------------

type _OpenNewPage = AssertAssignable<OpenNewPageRequest, { action: "openNewPage"; params: { url: string } }>

type _ClosePage = AssertAssignable<ClosePageRequest, { action: "closePage"; params: { pageId: string } }>

type _SwitchToPage = AssertAssignable<SwitchToPageRequest, { action: "switchToPage"; params: { pageId: string } }>

type _GetPages = AssertAssignable<GetPagesRequest, { action: "getPages"; params: Record<string, never> }>

type _GetCurrentPage = AssertAssignable<
  GetCurrentPageRequest,
  { action: "getCurrentPage"; params: Record<string, never> }
>

type _WaitForPopup = AssertAssignable<
  WaitForPopupRequest,
  {
    action: "waitForPopup"
    params: { triggerAction: string; triggerParams: Record<string, unknown> }
  }
>

// ---------------------------------------------------------------------------
// 3. New types are included in the PatrolNativeRequest union
// ---------------------------------------------------------------------------

type _UnionIncludesOpenNewPage = AssertAssignable<
  OpenNewPageRequest,
  Extract<PatrolNativeRequest, { action: "openNewPage" }>
>
type _UnionIncludesClosePage = AssertAssignable<ClosePageRequest, Extract<PatrolNativeRequest, { action: "closePage" }>>
type _UnionIncludesSwitchToPage = AssertAssignable<
  SwitchToPageRequest,
  Extract<PatrolNativeRequest, { action: "switchToPage" }>
>
type _UnionIncludesGetPages = AssertAssignable<GetPagesRequest, Extract<PatrolNativeRequest, { action: "getPages" }>>
type _UnionIncludesGetCurrentPage = AssertAssignable<
  GetCurrentPageRequest,
  Extract<PatrolNativeRequest, { action: "getCurrentPage" }>
>
type _UnionIncludesWaitForPopup = AssertAssignable<
  WaitForPopupRequest,
  Extract<PatrolNativeRequest, { action: "waitForPopup" }>
>

// ---------------------------------------------------------------------------
// Runtime structure tests
// ---------------------------------------------------------------------------

test.describe("contract types - new multi-tab requests", () => {
  test("OpenNewPageRequest has correct structure", () => {
    const req: OpenNewPageRequest = { action: "openNewPage", params: { url: "https://example.com" } }
    expect(req.action).toBe("openNewPage")
    expect(req.params).toEqual({ url: "https://example.com" })
  })

  test("ClosePageRequest has correct structure", () => {
    const req: ClosePageRequest = { action: "closePage", params: { pageId: "tab_1" } }
    expect(req.action).toBe("closePage")
    expect(req.params).toEqual({ pageId: "tab_1" })
  })

  test("SwitchToPageRequest has correct structure", () => {
    const req: SwitchToPageRequest = { action: "switchToPage", params: { pageId: "tab_2" } }
    expect(req.action).toBe("switchToPage")
    expect(req.params).toEqual({ pageId: "tab_2" })
  })

  test("GetPagesRequest has correct structure", () => {
    const req: GetPagesRequest = { action: "getPages", params: {} }
    expect(req.action).toBe("getPages")
    expect(req.params).toEqual({})
  })

  test("GetCurrentPageRequest has correct structure", () => {
    const req: GetCurrentPageRequest = { action: "getCurrentPage", params: {} }
    expect(req.action).toBe("getCurrentPage")
    expect(req.params).toEqual({})
  })

  test("WaitForPopupRequest has correct structure", () => {
    const req: WaitForPopupRequest = {
      action: "waitForPopup",
      params: { },
    }
    expect(req.action).toBe("waitForPopup")
    expect(req.params).toEqual({})
  })
})

test.describe("contract types - union includes new request types", () => {
  test("PatrolNativeRequest union accepts all new tab types", () => {
    const requests: PatrolNativeRequest[] = [
      { action: "openNewPage", params: { url: "https://example.com" } },
      { action: "closePage", params: { pageId: "page_1" } },
      { action: "switchToPage", params: { pageId: "page_2" } },
      { action: "getPages", params: {} },
      { action: "getCurrentPage", params: {} },
      { action: "waitForPopup", params: { triggerAction: "tap", triggerParams: {} } },
    ]
    expect(requests).toHaveLength(6)
  })
})
