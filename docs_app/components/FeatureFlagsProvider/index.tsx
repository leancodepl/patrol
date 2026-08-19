"use client"

import { FeatureFlagsProvider, bindPostHogClient } from "@/lib/posthog/posthog"
import type { PostHog } from "posthog-js"
import { useEffect } from "react"

declare global {
  interface Window {
    posthog?: PostHog & { __loaded?: boolean }
  }
}

function isPostHogReady(client: PostHog | undefined): client is PostHog {
  return Boolean(client && (client as PostHog & { __loaded?: boolean }).__loaded)
}

/**
 * PostHog is initialized outside the app (GTM / HTML snippet), including consent gating.
 * This provider only binds OpenFeature to `window.posthog` once that instance is ready.
 * It never calls `posthog.init` itself.
 */
export function AppFeatureFlagsProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    if (isPostHogReady(window.posthog)) {
      bindPostHogClient(window.posthog)
      return
    }

    const intervalId = window.setInterval(() => {
      if (isPostHogReady(window.posthog)) {
        window.clearInterval(intervalId)
        bindPostHogClient(window.posthog)
      }
    }, 50)

    return () => {
      window.clearInterval(intervalId)
    }
  }, [])

  return <FeatureFlagsProvider>{children}</FeatureFlagsProvider>
}
