import {
  ErrorCode,
  StandardResolutionReasons,
  type JsonValue,
  type Provider,
  type ResolutionDetails,
} from "@openfeature/web-sdk"

export type EvaluatedFlags = Record<string, boolean | string>

export class StaticFlagsProvider implements Provider {
  readonly metadata = { name: "StaticFlags" } as const
  readonly runsOn = "client" as const

  constructor(private readonly flags: EvaluatedFlags) {}

  resolveBooleanEvaluation(flagKey: string, defaultValue: boolean): ResolutionDetails<boolean> {
    const value = this.flags[flagKey]
    if (value === undefined) {
      return { value: defaultValue, reason: StandardResolutionReasons.DEFAULT }
    }

    return { value: Boolean(value), reason: StandardResolutionReasons.STATIC }
  }

  resolveStringEvaluation(flagKey: string, defaultValue: string): ResolutionDetails<string> {
    const value = this.flags[flagKey]
    if (value === undefined) {
      return { value: defaultValue, reason: StandardResolutionReasons.DEFAULT }
    }

    return { value: String(value), reason: StandardResolutionReasons.STATIC }
  }

  resolveNumberEvaluation(flagKey: string, defaultValue: number): ResolutionDetails<number> {
    const value = this.flags[flagKey]
    if (value === undefined) {
      return { value: defaultValue, reason: StandardResolutionReasons.DEFAULT }
    }

    const parsed = Number(value)
    if (Number.isNaN(parsed)) {
      return { value: defaultValue, errorCode: ErrorCode.TYPE_MISMATCH, reason: StandardResolutionReasons.ERROR }
    }

    return { value: parsed, reason: StandardResolutionReasons.STATIC }
  }

  resolveObjectEvaluation<T extends JsonValue>(flagKey: string, defaultValue: T): ResolutionDetails<T> {
    return { value: defaultValue, reason: StandardResolutionReasons.DEFAULT }
  }
}
