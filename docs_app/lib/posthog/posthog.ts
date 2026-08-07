import { mkFeatureFlags } from "@leancodepl/feature-flags-react-client"
import { OpenFeaturePosthogProvider } from "@leancodepl/openfeature-posthog-provider"
import posthog from "posthog-js"

export const featureFlags = {} as const

export const experiments = {} as const

const allFlags = {
  ...featureFlags,
  ...experiments,
}

const provider = new OpenFeaturePosthogProvider(posthog)

const { FeatureFlagsProvider, useFeatureFlag: useOpenFeatureFlag } = mkFeatureFlags(allFlags, provider)

export { FeatureFlagsProvider }

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
