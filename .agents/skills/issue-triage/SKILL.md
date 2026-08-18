---
name: issue-triage
description: Triage an incoming GitHub issue on leancodepl/patrol and produce a short, evidence-based recommendation — Patrol bug / User issue / Information needed / Feature / Docs / Duplicate / Out-of-scope — for a human to act on. Use during the weekly triage rotation, or when asked "triage issue #NNNN", "is this a Patrol bug or user error?", "what's wrong with this report?". Read-only: it recommends, a human decides.
---

# Triaging a Patrol issue

Turn one incoming issue into a **recommendation a human can act on in seconds**. You
guess; the human decides. Output is a tight summary of what you *confirmed* vs what you
*assume* — never a wall of text.

This skill is **orchestration + a catalog of the issues that actually recur**. The
catalog lives in [`references/common-issues.md`](references/common-issues.md) — read it
every run; it's what lets you triage without re-reading dozens of past issues.

## Hard rules

- **Read-only.** Do NOT comment, label, close, or edit the issue. Produce the
  recommendation (and a ready-to-paste reply the human *may* choose to send). The human
  applies labels and posts.
- **Don't guess versions or facts.** If the version triple, logs, or repro aren't in the
  issue, that absence *is* the finding (→ likely "Information needed").
- **Reproduction beats theory.** The strongest evidence for "Patrol bug" is a repro in
  Patrol's own `dev/e2e_app` or a reproducible example the reporter attached; the strongest evidence for "User issue" is that it only breaks in the reporter's project. Reproduce when it's cheap and would sharpen the verdict — and a **device-free repro** (a `patrol_finders` widget test, a CLI-only case) is exactly that cheap case: one `flutter test`/command, no device. Run it during triage instead of theorising.

## Where you're running

- **Locally** — you can reproduce (build/run `dev/e2e_app`, boot an emulator). Do so when
  it would flip a verdict between Patrol-bug and user-error.
- **On CI** — no devices/emulators/Xcode. You **cannot** verify anything device-,
  build-, or platform-dependent. Say so, lower your confidence, and recommend
  "reproduce locally" rather than asserting a bug/no-bug. Static triage (version
  compatibility, missing-info, duplicate search, feature/docs classification) is still valid.
  Exception: a **device-free repro** (a pure `patrol_finders` widget test, a CLI-only case)
  *is* runnable on CI — reproduce those instead of deferring them.

## Procedure

1. **Read the issue in full, with comments.**
   `gh issue view <n> --repo leancodepl/patrol --comments` (if the plain view returns empty,
   fall back to `--json body,comments,labels,author`). Note the reporter's later comments —
   the real cause often surfaces there (verbose logs, "works on emulator", etc.).
2. **Extract the facts grid** — what's present vs missing:
   versions (`patrol`, `patrol_cli`, `flutter`), `patrol doctor`, device vs emulator + OS/API
   level, platform (Android/iOS/web/CI), the exact command run, the exact error, and whether
   a **minimal reproducible repo** was shared. This grid drives everything below.
3. **Match the catalog first.** Check [`references/common-issues.md`](references/common-issues.md)
   — most reports match a known signature (version mismatch, `connectedDebugAndroidTest`
   failing, `xcodebuild 65`, bad `test_bundle.dart` import, forbidden char in test name, …).
   A catalog hit usually gives you the verdict, the confirmation step, and the reply text.
4. **If no catalog hit, apply the decision signals** (below) to pick a verdict.
5. **Duplicate check.** Search open + closed issues for the symptom before concluding:
   `gh issue list --repo leancodepl/patrol --state all --search "<key error phrase>"`.
   The catalog lists the canonical "duplicate magnet" issues.
6. **Verify if it's cheap and decisive** (local only) — reproduce in `dev/e2e_app`, or check
   the version pair against the [compatibility table](https://patrol.leancode.co/documentation/compatibility-table).
7. **Write the recommendation** in the output format below.

## Decision signals

Pick the **primary** verdict from these. A split is allowed and expected — if it's
genuinely 60/40, say so and give both (the human breaks the tie).

**Patrol bug** — reproducible in `dev/e2e_app`/`packages/patrol/example`; cites a
Patrol-generated file or internal source by path (`test_bundle.dart`, `Automator.swift`,
`app_options.dart`); a clean "worked before upgrading X" regression boundary; a documented
Patrol flag/API not behaving as specified.

> Caution: a regression boundary tells you **when** behaviour changed, not **whether** it's a
> defect — an intentional change with a thin changelog looks identical. Check the PR/changelog
> intent (`git log`, the release PR); if the change was deliberate it's **by-design (± docs gap)**, not a bug.

**User issue** (setup error/project specific problem) — only breaks in the reporter's project;
version pair violates the compatibility table; ran `flutter test` instead of `patrol test`;
native wiring wrong (`MainActivityTest.java` package, missing runner); stack trace lands in
*app* packages (`get_it`, DI, their `main()`); fails on one physical device / OEM skin while
green everywhere else; wrong `bundle_id`/`package_name`.

**Information needed** — no versions, no `--verbose` logs, no repro repo; placeholder
template blocks left unfilled; logs pasted as screenshots; vague "doesn't work". This is the
**#3145 archetype**: the report doesn't yet contain enough to act on. Default here when you
can't tell bug from user-error *because the report lacks the detail to decide* — ask for the
missing artifacts rather than over-analyzing.

**Feature request** — asks for a capability that doesn't exist yet ("add native `X()`",
"support for X", "it would be great if"); body uses the `### Use case` + `### Proposal`
template. A "bug" that is actually behaviour-by-design (app relaunch between tests, hit-testable
== visible) is a feature/wontfix, not a bug.

**Docs gap** — asks a question rather than reporting a failure ("is it OK to gitignore
`test_bundle.dart`?"); "not documented anywhere"; broken link / stale README; a
looks-like-a-bug env issue whose real fix is an FAQ entry.

**Duplicate** — symptom matches an existing issue (see the catalog's duplicate-magnet list).
Recommend "Duplicate of #X", don't re-triage the underlying problem.

**Out-of-scope / wontfix** — blocked by native-platform limits, or a large risky refactor the
team has already declined (transport rewrite, run-without-installing, websockets). The catalog
lists the recurring ones.

## Output format (keep it tight — no bloat)

```
**#<n> <title>**
Verdict: <Primary> (<confidence %>)[ · secondary: <Other> (<%>)]
Why: <one sentence>

Confirmed (from the issue):
- <fact / version / error / platform actually stated — not inferred>

Assessment (best guess):
- <what's most likely happening, and the signal that points there>
- <catalog match: see common-issues.md "<card name>"> (if any)

Missing / would confirm it:
- <specific artifact to ask for, or the local repro that would decide it>

Duplicate of: #<x>  (omit if none)

Suggested action for the human:
- Label(s): <e.g. needs more info, waiting for response / bug + package:… / feature>
- <"reproduce locally" | "close as duplicate" | "ready-to-paste reply below">

Draft reply (optional, do NOT post):
> <short, specific, links the exact doc anchor — see common-issues.md for canned replies>
```

Rules for the output:
- **Confirmed = only what the issue literally states.** Everything speculative goes under
  Assessment. Never blur the two — that separation is the whole point.
- Cite issue numbers you compared against.
- If running on CI, add one line: `Note: CI run — device/build behaviour not verified.`
- No preamble, no restating the issue back at length. A triager should read it in ~20 seconds.

## Keeping the catalog useful

If you triage something that clearly recurs and isn't in the catalog, note it at the end of
your output as **"catalog candidate"** so a human can add it. Don't grow the catalog with
one-off edge cases — only patterns seen repeatedly. It's a shortlist, not an issue archive.
