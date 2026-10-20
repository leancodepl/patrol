## Unreleased

- Requires `patrol_cli` 4.10.0-dev.1 or newer, and with it Flutter 3.47.0 or newer for web develop.
- Support web develop sessions: the `devices` tool now lists browsers (e.g. `chrome`) and `run`
  accepts them as `device`. Web is never auto-selected, since a browser is rarely what "run the
  test" means when a phone is attached, so pass it explicitly. `native-tree` remains Android and
  iOS only.
- Drop the web-specific session handling that existed only because `patrol develop` on web
  restarted cold. Web sessions now stay alive across hot restarts like mobile ones, so there are no
  stale completion callbacks to suppress and no orphaned Flutter or Chrome process to force-kill.
- Bound the CDP HTTP discovery phase when taking a web screenshot, so a browser that never answers
  fails the tool instead of hanging it.

## 0.2.2

- Fix the `devices` tool and device auto-selection in `run` on Windows (#3298).

## 0.2.1


## 0.2.0



## 0.1.4


## 0.1.3


## 0.1.2


## 0.1.1


## 0.1.0

