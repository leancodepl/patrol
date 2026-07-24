import type { PostHogBootstrap } from "@/lib/posthog/posthog-bootstrap"
import { cookies } from "next/headers"
import { PostHog } from "posthog-node"
import { cache } from "react"

export type { PostHogBootstrap }

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

async function readDistinctId() {
  const token = process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN
  if (!token) {
    return crypto.randomUUID()
  }

  const cookieStore = await cookies()
  const cookie = cookieStore.get(`ph_${token}_posthog`)
  if (!cookie?.value) {
    return crypto.randomUUID()
  }

  try {
    const parsed = JSON.parse(cookie.value) as { distinct_id?: string }
    return parsed.distinct_id ?? crypto.randomUUID()
  } catch {
    return crypto.randomUUID()
  }
}

export const getPostHogBootstrap = cache(async (): Promise<PostHogBootstrap | undefined> => {
  const client = createPostHogServerClient()
  if (!client) {
    return undefined
  }

  const distinctID = await readDistinctId()

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
