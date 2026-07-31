declare global {
  interface Window {
    __patrol__getTests?: () => { group: DartTestEntry }
    __patrol__runTest?: (name: string) => Promise<PatrolTestResult>
    __patrol__onInitialised?: () => void
    __patrol__isInitialised?: boolean
  }
}

export type PatrolTestEntry = {
  name: string
  skip: boolean
  tags: string[]
}

export type PatrolTestResult = {
  result: "failure" | "success"
  details: string | null
}

export type DartTestEntry = {
  type: "group" | "test"
  name: string
  entries: DartTestEntry[]
  skip: boolean
  tags: string[]
}
