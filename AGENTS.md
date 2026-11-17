# Agent instructions

## Patrol 5.0

`release/5.0` leads to Patrol 5.0. `migration5.md` collects everything users
have to do when they upgrade.

When a change is breaking or asks users to act on upgrade, add a line to the
Inbox at the end of `migration5.md` in the same PR. That covers a removed or
renamed API, a new minimum version, a changed default, a new setup step, and
anything marked breaking: `!` in a commit or PR title, a breaking-change note
in a changelog. A rough line is enough. When unsure whether a change qualifies,
add the line.

When Patrol 5.0.0 is released, remove this section, and this file and
`CLAUDE.md` if nothing else is left in them.
