import { test, expect } from "@playwright/test"
import type {
  TapRequest,
  EnterTextRequest,
  ScrollToRequest,
  OpenNewTabRequest,
  CloseTabRequest,
  SwitchToTabRequest,
  GetTabsRequest,
  GetCurrentTabRequest,
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
// 1. Existing requests still work WITHOUT tabId
// ---------------------------------------------------------------------------

type _TapWithoutTabId = AssertAssignable<
  TapRequest,
  {
    action: "tap"
    params: {
      selector: {
        role: null; label: null; placeholder: null; text: null
        altText: null; title: null; testId: null; cssOrXpath: null
      }
      iframeSelector: null
    }
  }
>

// ---------------------------------------------------------------------------
// 2. _routeToTab is optional on all requests (spot-check TapRequest, EnterTextRequest, ScrollToRequest)
// ---------------------------------------------------------------------------

type _TapWithRouteToTab = AssertAssignable<
  TapRequest,
  {
    action: "tap"
    params: {
      selector: {
        role: null; label: null; placeholder: null; text: null
        altText: null; title: null; testId: null; cssOrXpath: null
      }
      iframeSelector: null
      _routeToTab: "tab_1"
    }
  }
>

type _EnterTextWithRouteToTab = AssertAssignable<
  EnterTextRequest,
  {
    action: "enterText"
    params: {
      selector: {
        role: null; label: null; placeholder: null; text: null
        altText: null; title: null; testId: null; cssOrXpath: null
      }
      text: "hello"
      iframeSelector: null
      _routeToTab: "tab_2"
    }
  }
>

type _ScrollToWithRouteToTab = AssertAssignable<
  ScrollToRequest,
  {
    action: "scrollTo"
    params: {
      selector: {
        role: null; label: null; placeholder: null; text: null
        altText: null; title: null; testId: null; cssOrXpath: null
      }
      iframeSelector: null
      _routeToTab: "tab_3"
    }
  }
>

// ---------------------------------------------------------------------------
// 3. New request types exist and have the correct shape
// ---------------------------------------------------------------------------

type _OpenNewTab = AssertAssignable<
  OpenNewTabRequest,
  { action: "openNewTab"; params: { url: string } }
>

type _CloseTab = AssertAssignable<
  CloseTabRequest,
  { action: "closeTab"; params: { tabId: string } }
>

type _SwitchToTab = AssertAssignable<
  SwitchToTabRequest,
  { action: "switchToTab"; params: { tabId: string } }
>

type _GetTabs = AssertAssignable<
  GetTabsRequest,
  { action: "getTabs"; params: Record<string, never> }
>

type _GetCurrentTab = AssertAssignable<
  GetCurrentTabRequest,
  { action: "getCurrentTab"; params: Record<string, never> }
>

type _WaitForPopup = AssertAssignable<
  WaitForPopupRequest,
  {
    action: "waitForPopup"
    params: { triggerAction: string; triggerParams: Record<string, unknown> }
  }
>

// ---------------------------------------------------------------------------
// 4. New types are included in the PatrolNativeRequest union
// ---------------------------------------------------------------------------

type _UnionIncludesOpenNewTab = AssertAssignable<OpenNewTabRequest, Extract<PatrolNativeRequest, { action: "openNewTab" }>>
type _UnionIncludesCloseTab = AssertAssignable<CloseTabRequest, Extract<PatrolNativeRequest, { action: "closeTab" }>>
type _UnionIncludesSwitchToTab = AssertAssignable<SwitchToTabRequest, Extract<PatrolNativeRequest, { action: "switchToTab" }>>
type _UnionIncludesGetTabs = AssertAssignable<GetTabsRequest, Extract<PatrolNativeRequest, { action: "getTabs" }>>
type _UnionIncludesGetCurrentTab = AssertAssignable<GetCurrentTabRequest, Extract<PatrolNativeRequest, { action: "getCurrentTab" }>>
type _UnionIncludesWaitForPopup = AssertAssignable<WaitForPopupRequest, Extract<PatrolNativeRequest, { action: "waitForPopup" }>>

// ---------------------------------------------------------------------------
// Runtime structure tests
// ---------------------------------------------------------------------------

test.describe("contract types - new multi-tab requests", () => {
  test("OpenNewTabRequest has correct structure", () => {
    const req: OpenNewTabRequest = { action: "openNewTab", params: { url: "https://example.com" } }
    expect(req.action).toBe("openNewTab")
    expect(req.params).toEqual({ url: "https://example.com" })
  })

  test("CloseTabRequest has correct structure", () => {
    const req: CloseTabRequest = { action: "closeTab", params: { tabId: "tab_1" } }
    expect(req.action).toBe("closeTab")
    expect(req.params).toEqual({ tabId: "tab_1" })
  })

  test("SwitchToTabRequest has correct structure", () => {
    const req: SwitchToTabRequest = { action: "switchToTab", params: { tabId: "tab_2" } }
    expect(req.action).toBe("switchToTab")
    expect(req.params).toEqual({ tabId: "tab_2" })
  })

  test("GetTabsRequest has correct structure", () => {
    const req: GetTabsRequest = { action: "getTabs", params: {} }
    expect(req.action).toBe("getTabs")
    expect(req.params).toEqual({})
  })

  test("GetCurrentTabRequest has correct structure", () => {
    const req: GetCurrentTabRequest = { action: "getCurrentTab", params: {} }
    expect(req.action).toBe("getCurrentTab")
    expect(req.params).toEqual({})
  })

  test("WaitForPopupRequest has correct structure", () => {
    const req: WaitForPopupRequest = {
      action: "waitForPopup",
      params: { triggerAction: "tap", triggerParams: { selector: "button" } },
    }
    expect(req.action).toBe("waitForPopup")
    expect(req.params.triggerAction).toBe("tap")
    expect(req.params.triggerParams).toEqual({ selector: "button" })
  })
})

test.describe("contract types - _routeToTab is optional on existing requests", () => {
  test("TapRequest accepts _routeToTab in params", () => {
    const req: TapRequest = {
      action: "tap",
      params: {
        selector: {
          role: null, label: null, placeholder: null, text: null,
          altText: null, title: null, testId: null, cssOrXpath: null,
        },
        iframeSelector: null,
        _routeToTab: "tab_1",
      },
    }
    expect(req.params._routeToTab).toBe("tab_1")
  })

  test("TapRequest works without _routeToTab (backward compatible)", () => {
    const req: TapRequest = {
      action: "tap",
      params: {
        selector: {
          role: null, label: null, placeholder: null, text: null,
          altText: null, title: null, testId: null, cssOrXpath: null,
        },
        iframeSelector: null,
      },
    }
    expect(req.params).not.toHaveProperty("_routeToTab")
  })
})

test.describe("contract types - union includes new request types", () => {
  test("PatrolNativeRequest union accepts all new tab types", () => {
    const requests: PatrolNativeRequest[] = [
      { action: "openNewTab", params: { url: "https://example.com" } },
      { action: "closeTab", params: { tabId: "tab_1" } },
      { action: "switchToTab", params: { tabId: "tab_2" } },
      { action: "getTabs", params: {} },
      { action: "getCurrentTab", params: {} },
      { action: "waitForPopup", params: { triggerAction: "tap", triggerParams: {} } },
    ]
    expect(requests).toHaveLength(6)
  })
})
