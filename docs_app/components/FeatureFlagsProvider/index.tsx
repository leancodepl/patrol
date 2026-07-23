"use client"

import { FeatureFlagsProvider } from "@/lib/posthog/posthog"
import type { PostHogBootstrap } from "@/lib/posthog/posthog-bootstrap"
import posthog from "posthog-js"
import { useRef } from "react"

declare global {
  interface Window {
    CookieScript?: {
      instance?: {
        currentState?: () => {
          action: "accept" | "reject"
          categories: string[]
        }
      }
    }
  }

  interface WindowEventMap {
    CookieScriptLoaded: Event
    CookieScriptAcceptAll: Event
    CookieScriptAccept: CustomEvent<{ categories: string[] }>
    CookieScriptReject: Event
  }
}

const ANALYTICS_CATEGORIES = new Set(["performance", "targeting"])

function hasAnalyticsConsent(categories: string[] | undefined) {
  return categories?.some(category => ANALYTICS_CATEGORIES.has(category)) ?? false
}

function applyAnalyticsConsent(granted: boolean) {
  if (granted) {
    posthog.opt_in_capturing()
  } else {
    posthog.opt_out_capturing()
  }
}

function syncConsentFromCookieScript() {
  const state = window.CookieScript?.instance?.currentState?.()
  if (!state) {
    return
  }

  applyAnalyticsConsent(state.action === "accept" && hasAnalyticsConsent(state.categories))
}

function initPostHog(bootstrap?: PostHogBootstrap) {
  if (typeof window === "undefined" || (posthog as { __loaded?: boolean }).__loaded) {
    return
  }

  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    defaults: "2026-06-25",
    opt_out_capturing_by_default: true,
    bootstrap,
    advanced_disable_feature_flags_on_first_load: Boolean(bootstrap),
  })

  window.addEventListener("CookieScriptLoaded", syncConsentFromCookieScript)
  window.addEventListener("CookieScriptAcceptAll", () => applyAnalyticsConsent(true))
  window.addEventListener("CookieScriptAccept", event => {
    applyAnalyticsConsent(hasAnalyticsConsent(event.detail?.categories))
  })
  window.addEventListener("CookieScriptReject", () => applyAnalyticsConsent(false))

  if (window.CookieScript?.instance) {
    syncConsentFromCookieScript()
  }
}

export function AppFeatureFlagsProvider({
  children,
  bootstrap,
}: {
  children: React.ReactNode
  bootstrap?: PostHogBootstrap
}) {
  const didInit = useRef(false)

  if (typeof window !== "undefined" && !didInit.current) {
    initPostHog(bootstrap)
    didInit.current = true
  }

  return <FeatureFlagsProvider>{children}</FeatureFlagsProvider>
}
