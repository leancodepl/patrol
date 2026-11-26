import { TestInfo } from "@playwright/test"

const patrolLogPrefix = "PATROL_LOG "

/** What the Dart side has reported, through PATROL_LOG lines, for the test that is running. */
export type DartTestProgress = {
  started: boolean
  finished: boolean
}

type PatrolLogTestEntry = {
  type: "test"
  name: string
  status: "start" | "failure"
  timestamp: string
  error?: string
}

/** Updates [progress] from a PATROL_LOG line printed by the app. Other lines are ignored. */
export function trackDartTestProgress(line: string, progress: DartTestProgress) {
  if (!line.startsWith(patrolLogPrefix)) return

  let entry: unknown
  try {
    entry = JSON.parse(line.slice(patrolLogPrefix.length))
  } catch {
    return
  }

  if (typeof entry !== "object" || entry === null) return
  const { type, status } = entry as { type?: unknown; status?: unknown }
  if (type !== "test") return

  if (status === "start") {
    progress.started = true
  } else if (status === "success" || status === "failure") {
    progress.finished = true
  }
}

/** Playwright colors some messages, e.g. test timeouts. */
// eslint-disable-next-line no-control-regex
const ansiColor = /\u001b\[[0-9;]*m/g

/**
 * Returns the PATROL_LOG lines that report a test Playwright failed before the Dart test reported
 * its result, e.g. when the page fixture timed out waiting for the app to start. Patrol builds its
 * summary from PATROL_LOG lines only, so without them such a test is missing from it.
 *
 * Returns nothing when:
 * - the test ended as expected, or the Dart test already reported a result,
 * - the test is marked as skipped (the Dart side reports skipped tests itself),
 * - Playwright will retry the test, so a test that passes on a retry doesn't fail the run. The last
 *   attempt is reported. Playwright retries only failed and timed-out tests: an interrupted test
 *   (the run was stopped, e.g. by the global timeout or Ctrl+C) gets no retry, so it is reported.
 */
export function unreportedFailureLines(
  test: { name: string; skip: boolean },
  progress: DartTestProgress,
  testInfo: Pick<TestInfo, "status" | "expectedStatus" | "error" | "retry"> & {
    project: Pick<TestInfo["project"], "retries">
  },
  now: () => Date = () => new Date(),
): string[] {
  if (testInfo.status === testInfo.expectedStatus || progress.finished) return []
  const willRetry =
    testInfo.retry < testInfo.project.retries && (testInfo.status === "failed" || testInfo.status === "timedOut")
  if (test.skip || willRetry) return []

  const { name } = test
  const entries: PatrolLogTestEntry[] = []
  if (!progress.started) {
    entries.push({ type: "test", name, status: "start", timestamp: now().toISOString() })
  }
  entries.push({
    type: "test",
    name,
    status: "failure",
    timestamp: now().toISOString(),
    error: firstLine(testInfo.error?.message) ?? `Playwright test ${testInfo.status}`,
  })

  return entries.map(entry => `${patrolLogPrefix}${JSON.stringify(entry)}`)
}

function firstLine(message: string | undefined) {
  const line = message?.replace(ansiColor, "").split("\n")[0].trim()
  return line ? line : undefined
}
