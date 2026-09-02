"use client"

import { FeatureFlagsProvider, bindPostHogClient, bindServerFlags } from "@/lib/posthog/posthog"
import type { EvaluatedFlags } from "@/lib/posthog/posthog"
import type { PostHog } from "posthog-js"
import { useEffect, useRef } from "react"

declare global {
  interface Window {
    posthog?: PostHog & { __loaded?: boolean }
  }
}

function isPostHogReady(client: PostHog | undefined): client is PostHog {
  return Boolean(client && (client as PostHog & { __loaded?: boolean }).__loaded)
}

/**
 * Seeds flags from the server (no posthog-js). If GTM later initializes PostHog,
 * OpenFeature switches to that client. Never calls `posthog.init`.
 */
export function AppFeatureFlagsProvider({
  children,
  flags,
}: {
  children: React.ReactNode
  flags: EvaluatedFlags
}) {
  const posthogBound = useRef(false)

  if (!posthogBound.current) {
    bindServerFlags(flags)
  }

  useEffect(() => {
    if (isPostHogReady(window.posthog)) {
      bindPostHogClient(window.posthog)
      posthogBound.current = true
      return
    }

    const intervalId = window.setInterval(() => {
      if (isPostHogReady(window.posthog)) {
        window.clearInterval(intervalId)
        bindPostHogClient(window.posthog)
        posthogBound.current = true
      }
    }, 50)

    return () => {
      window.clearInterval(intervalId)
    }
  }, [])

  return <FeatureFlagsProvider>{children}</FeatureFlagsProvider>
}
