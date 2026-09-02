import { cookies } from "next/headers"
import { cache } from "react"
import { PostHog } from "posthog-node"
import type { EvaluatedFlags } from "@/lib/posthog/static-flags-provider"

const ANONYMOUS_DISTINCT_ID = "anonymous"

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
 */
function getPostHogCookieName(apiKey: string) {
  const sanitized = apiKey.replaceAll("+", "PL").replaceAll("/", "SL").replaceAll("=", "EQ")
  return `ph_${sanitized}_posthog`
}

async function readDistinctId() {
  const token = process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN
  if (!token) {
    return ANONYMOUS_DISTINCT_ID
  }

  const cookieStore = await cookies()
  const cookie = cookieStore.get(getPostHogCookieName(token))
  if (!cookie?.value) {
    return ANONYMOUS_DISTINCT_ID
  }

  try {
    const parsed = JSON.parse(cookie.value) as { distinct_id?: string }
    return parsed.distinct_id ?? ANONYMOUS_DISTINCT_ID
  } catch {
    return ANONYMOUS_DISTINCT_ID
  }
}

export const getServerFlags = cache(async (): Promise<EvaluatedFlags> => {
  const client = createPostHogServerClient()
  if (!client) {
    return {}
  }

  const distinctID = await readDistinctId()

  try {
    const { featureFlags } = await client.getAllFlagsAndPayloads(distinctID)
    return featureFlags ?? {}
  } catch {
    return {}
  } finally {
    await client.shutdown()
  }
})

export async function getServerFeatureFlag(key: string) {
  const flags = await getServerFlags()
  return flags[key]
}

export async function getServerExperiment(key: string) {
  const value = await getServerFeatureFlag(key)
  return typeof value === "string" ? value : undefined
}
