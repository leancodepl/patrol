import { spawn, type ChildProcess } from "node:child_process"
import { createServer, type Server } from "node:http"
import type { AddressInfo } from "node:net"
import { dirname, join } from "node:path"
import { chromium, expect, test, type BrowserServer, type FullConfig } from "@playwright/test"
import setup from "../setup"

// A stand-in for a Flutter app built with Patrol: it reports one group with a
// single test once the runner has initialised it.
const APP_HTML = `<!doctype html>
<script>
  window.__patrol__onInitialised = () => {
    window.__patrol__getTests = () => ({
      group: {
        type: "group", name: "", skip: false, tags: [],
        entries: [
          navigator.userAgent === "PatrolRemoteServerTest"
            ? { type: "test", name: navigator.userAgent, entries: [], skip: false, tags: [] }
            : { type: "test", name: "remote test", entries: [], skip: false, tags: ["web"] },
        ],
      },
    })
  }
</script>`

let appServer: Server
let baseURL: string
let browserServer: BrowserServer

test.beforeAll(async () => {
  appServer = createServer((_, response) => {
    response.setHeader("Content-Type", "text/html")
    response.end(APP_HTML)
  })
  await new Promise<void>(resolve => appServer.listen(0, "127.0.0.1", resolve))
  baseURL = `http://127.0.0.1:${(appServer.address() as AddressInfo).port}`
  browserServer = await chromium.launchServer()
})

test.afterAll(async () => {
  await browserServer?.close()
  await new Promise(resolve => appServer?.close(resolve))
})

function configWith(use: FullConfig["projects"][number]["use"]) {
  return { projects: [{ use: { baseURL, ...use } }] } as unknown as FullConfig
}

test.afterEach(() => {
  delete process.env.PATROL_TESTS
})

test("discovers the tests on a remote browser", async () => {
  await setup(configWith({ connectOptions: { wsEndpoint: browserServer.wsEndpoint() } }))

  expect(JSON.parse(process.env.PATROL_TESTS ?? "[]")).toEqual([{ name: "remote test", skip: false, tags: ["@web"] }])
})

test("connects instead of launching a local browser", async () => {
  // Nothing listens on port 1, so this only fails if setup really connects.
  await expect(
    setup(configWith({ connectOptions: { wsEndpoint: "ws://127.0.0.1:1/", timeout: 2000 } })),
  ).rejects.toThrow(/browserType\.connect/)
})

// chromium.launchServer() starts its browser up front and ignores the
// x-playwright-launch-options header, so the header path needs a real
// `playwright run-server`, like the one users run.
// The same CLI users run as `npx playwright run-server`.
const playwrightCli = join(dirname(require.resolve("playwright/package.json")), "cli.js")

test.describe("against playwright run-server", () => {
  let runServer: ChildProcess
  let wsEndpoint: string

  test.beforeAll(async () => {
    runServer = spawn(process.execPath, [playwrightCli, "run-server", "--port", "0", "--host", "127.0.0.1"])
    wsEndpoint = await new Promise<string>((resolve, reject) => {
      runServer.stdout?.on("data", (data: Buffer) => {
        const match = /Listening on (ws:\/\/\S+)/.exec(data.toString())
        if (match) resolve(match[1])
      })
      runServer.on("exit", code => reject(new Error(`run-server exited with code ${code}`)))
    })
  })

  test.afterAll(() => {
    runServer?.kill()
  })

  test("launches the browser with Patrol's launch options", async () => {
    await setup(
      configWith({
        connectOptions: { wsEndpoint },
        launchOptions: { args: ["--user-agent=PatrolRemoteServerTest"] },
      }),
    )

    // The stand-in app names its test after the browser's user agent.
    expect(JSON.parse(process.env.PATROL_TESTS ?? "[]")).toEqual([
      { name: "PatrolRemoteServerTest", skip: false, tags: [] },
    ])
  })
})
