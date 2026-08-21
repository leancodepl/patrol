import { cookies } from "next/headers"
import type { BootstrapConfig } from "posthog-js"
import { PostHog } from "posthog-node"
import { cache } from "react"

function createPostHogServerClient() {
  const token = process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN
  if (!token) {
    return null
  }

  return new PostHog(token, {
    host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    flushAt: 1,
    flushInterval: 0,
  })
}

/**
 * PostHog JS persistence cookie name: `ph_<project_api_key>_posthog`
 * @see https://posthog.com/docs/libraries/js/persistence
 *
 * The JS SDK sanitizes `+` / `/` / `=` in the token when building the name
 * (same helpers as in posthog-js / upcoming posthog-node exports).
 */
function getPostHogCookieName(apiKey: string) {
  const sanitized = apiKey.replaceAll("+", "PL").replaceAll("/", "SL").replaceAll("=", "EQ")
  return `ph_${sanitized}_posthog`
}

async function readDistinctId() {
  const token = process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN
  if (!token) {
    return undefined
  }

  const cookieStore = await cookies()
  const cookie = cookieStore.get(getPostHogCookieName(token))
  if (!cookie?.value) {
    // No client identity yet — skip SSR bootstrap so posthog-js owns distinct_id.
    return undefined
  }

  try {
    const parsed = JSON.parse(cookie.value) as { distinct_id?: string }
    return parsed.distinct_id
  } catch {
    return undefined
  }
}

export const getPostHogBootstrap = cache(async (): Promise<BootstrapConfig | undefined> => {
  const distinctID = await readDistinctId()
  if (!distinctID) {
    return undefined
  }

  const client = createPostHogServerClient()
  if (!client) {
    return undefined
  }

  try {
    const { featureFlags, featureFlagPayloads } = await client.getAllFlagsAndPayloads(distinctID)

    return {
      distinctID,
      featureFlags: featureFlags ?? {},
      featureFlagPayloads: featureFlagPayloads ?? {},
    }
  } catch {
    return {
      distinctID,
      featureFlags: {},
    }
  } finally {
    await client.shutdown()
  }
})

export async function getServerFeatureFlag(key: string) {
  const bootstrap = await getPostHogBootstrap()
  return bootstrap?.featureFlags?.[key]
}

export async function getServerExperiment(key: string) {
  const value = await getServerFeatureFlag(key)
  return typeof value === "string" ? value : undefined
}
