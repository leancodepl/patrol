import { mkFeatureFlags } from "@leancodepl/feature-flags-react-client"
import { OpenFeaturePosthogProvider } from "@leancodepl/openfeature-posthog-provider"
import { OpenFeature } from "@openfeature/web-sdk"
import posthog from "posthog-js"
import type { PostHog } from "posthog-js"

export const featureFlags = {} as const

export const experiments = {} as const

const allFlags = {
  ...featureFlags,
  ...experiments,
}

const { FeatureFlagsProvider, useFeatureFlag: useOpenFeatureFlag } = mkFeatureFlags(
  allFlags,
  new OpenFeaturePosthogProvider(posthog),
)

export { FeatureFlagsProvider }

/** Point OpenFeature at the live PostHog client (GTM/snippet `window.posthog` or npm). */
export function bindPostHogClient(client: PostHog) {
  OpenFeature.setProvider(new OpenFeaturePosthogProvider(client))
}

export function useFeatureFlag<TKey extends keyof typeof featureFlags>(
  key: TKey,
  defaultValue?: (typeof featureFlags)[TKey]["defaultValue"],
) {
  return useOpenFeatureFlag(key, defaultValue)
}

export function useExperiment<TKey extends keyof typeof experiments>(
  key: TKey,
  defaultValue?: (typeof experiments)[TKey]["defaultValue"],
) {
  return useOpenFeatureFlag(key, defaultValue)
}
