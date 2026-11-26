import { expect, test } from "@playwright/test"
import { DartTestProgress, trackDartTestProgress, unreportedFailureLines } from "../unreportedTests"

const now = () => new Date("2026-01-02T03:04:05.000Z")

function progress(started: boolean, finished: boolean): DartTestProgress {
  return { started, finished }
}

function info(status: string, expectedStatus: string, message?: string, retry = 0, retries = 0) {
  return {
    status: status as "passed",
    expectedStatus: expectedStatus as "passed",
    error: message === undefined ? undefined : { message },
    retry,
    project: { retries },
  }
}

const test1 = { name: "web_example_test opens the app", skip: false }

function parse(lines: string[]) {
  return lines.map(line => {
    expect(line.startsWith("PATROL_LOG ")).toBe(true)
    return JSON.parse(line.slice("PATROL_LOG ".length))
  })
}

test.describe("trackDartTestProgress", () => {
  test("marks the test as started and finished from test entries", () => {
    const p = progress(false, false)

    trackDartTestProgress('PATROL_LOG {"type":"test","name":"a","status":"start"}', p)
    expect(p).toEqual(progress(true, false))

    trackDartTestProgress('PATROL_LOG {"type":"test","name":"a","status":"failure"}', p)
    expect(p).toEqual(progress(true, true))
  })

  test("treats success as finished", () => {
    const p = progress(true, false)
    trackDartTestProgress('PATROL_LOG {"type":"test","name":"a","status":"success"}', p)
    expect(p.finished).toBe(true)
  })

  test("ignores skip, step and log entries", () => {
    const p = progress(false, false)
    trackDartTestProgress('PATROL_LOG {"type":"test","name":"a","status":"skip"}', p)
    trackDartTestProgress('PATROL_LOG {"type":"step","action":"tap","status":"start"}', p)
    trackDartTestProgress('PATROL_LOG {"type":"log","message":"hi"}', p)
    expect(p).toEqual(progress(false, false))
  })

  test("ignores lines that are not valid PATROL_LOG JSON", () => {
    const p = progress(false, false)
    trackDartTestProgress("PATROL_LOG {not json", p)
    trackDartTestProgress("PATROL_LOG null", p)
    trackDartTestProgress('flutter: {"type":"test","status":"start"}', p)
    expect(p).toEqual(progress(false, false))
  })
})

test.describe("unreportedFailureLines", () => {
  test("reports start and failure when the Dart test never started", () => {
    const lines = unreportedFailureLines(
      test1,
      progress(false, false),
      info("timedOut", "passed", '\u001b[31mTest timeout of 2000ms exceeded while setting up "page".\u001b[39m\nmore'),
      now,
    )

    expect(parse(lines)).toEqual([
      {
        type: "test",
        name: "web_example_test opens the app",
        status: "start",
        timestamp: "2026-01-02T03:04:05.000Z",
      },
      {
        type: "test",
        name: "web_example_test opens the app",
        status: "failure",
        timestamp: "2026-01-02T03:04:05.000Z",
        error: 'Test timeout of 2000ms exceeded while setting up "page".',
      },
    ])
  })

  test("reports only the failure when the Dart test started but did not finish", () => {
    const lines = unreportedFailureLines(
      test1,
      progress(true, false),
      info("timedOut", "passed", "Test timeout of 2000ms exceeded."),
      now,
    )

    expect(parse(lines).map(e => e.status)).toEqual(["failure"])
  })

  test("falls back to the Playwright status when there is no error message", () => {
    const lines = unreportedFailureLines(test1, progress(false, false), info("interrupted", "passed"))

    expect(parse(lines)[1].error).toBe("Playwright test interrupted")
  })

  test("reports the last attempt when retries are on", () => {
    expect(unreportedFailureLines(test1, progress(false, false), info("failed", "passed", "boom", 0, 2))).toEqual([])
    expect(unreportedFailureLines(test1, progress(false, false), info("failed", "passed", "boom", 1, 2))).toEqual([])
    expect(
      parse(unreportedFailureLines(test1, progress(false, false), info("failed", "passed", "boom", 2, 2))).map(
        e => e.status,
      ),
    ).toEqual(["start", "failure"])
  })

  test("reports an interrupted attempt even when retries are left", () => {
    // Playwright doesn't retry a test that was interrupted, e.g. by the global timeout.
    expect(
      parse(unreportedFailureLines(test1, progress(false, false), info("interrupted", "passed", undefined, 0, 2))).map(
        e => e.status,
      ),
    ).toEqual(["start", "failure"])
  })

  test("reports nothing for a test marked as skipped", () => {
    expect(
      unreportedFailureLines({ ...test1, skip: true }, progress(false, false), info("timedOut", "passed", "timeout")),
    ).toEqual([])
  })

  test("reports nothing when the Dart test already reported its result", () => {
    expect(unreportedFailureLines(test1, progress(true, true), info("failed", "passed", "boom"))).toEqual([])
  })

  test("reports nothing for tests that ended as expected", () => {
    expect(unreportedFailureLines(test1, progress(false, false), info("passed", "passed"))).toEqual([])
    expect(unreportedFailureLines(test1, progress(false, false), info("skipped", "skipped"))).toEqual([])
  })
})
