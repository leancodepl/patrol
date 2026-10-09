# Patrol docs — target structure

Target page tree for patrol.leancode.co, from the plan "Przebudowa docsów
Patrola" (11 Sep 2026).

- Paths are relative to `docs/` in `leancodepl/patrol`. URL = path without
  `.mdx`; `index.mdx` is the folder's URL.
- Order is sidebar order.
- `— Name —` is a sidebar group (a separator in `meta.json`), not a folder.

```
docs/
├── index.mdx                                  Patrol (landing page, outside the tabs)
│
├── get-started/                               TAB: Get Started
│   ├── index.mdx                              Getting started
│   ├── prerequisites.mdx                      Prerequisites
│   ├── install.mdx                            Install Patrol
│   ├── android-setup.mdx                      Android setup
│   ├── ios-setup.mdx                          iOS setup
│   ├── macos-setup.mdx                        macOS setup
│   ├── write-your-first-test.mdx              Write your first test
│   ├── run-and-debug.mdx                      Run and debug tests
│   └── run-on-ci.mdx                          Run on CI
│
├── guides/                                    TAB: Guides (one flat folder)
│   ├── index.mdx                              Guides
│   │   — Writing tests —
│   ├── finders.mdx                            Find, assert and interact with widgets
│   ├── finders-in-widget-tests.mdx            Finders in widget tests
│   ├── effective-patrol.mdx                   Effective Patrol
│   ├── tips-and-tricks.mdx                    Tips and tricks
│   │   — Platform automation —
│   ├── platform-automation.mdx                Platform automation
│   ├── permissions.mdx                        Permissions
│   ├── take-a-photo.mdx                       Take a photo
│   ├── pick-images-from-gallery.mdx           Pick images from gallery
│   ├── bluetooth.mdx                          Bluetooth
│   ├── pull-to-refresh.mdx                    Pull to refresh
│   ├── extension-packages.mdx                 Build an extension package
│   │   — Project setup —
│   ├── flavors.mdx                            Flavors and dart-define
│   ├── physical-ios-devices.mdx               Physical iOS devices
│   ├── web.mdx                                Web testing
│   │   — Running tests —
│   ├── tags.mdx                               Select tests with tags
│   ├── logs-and-reports.mdx                   Logs and reports
│   ├── build-time-test-discovery.mdx          Build-time test discovery
│   │   — Device farms and reporting —
│   ├── firebase-test-lab.mdx                  Firebase Test Lab
│   ├── browserstack.mdx                       BrowserStack
│   ├── saucelabs.mdx                          SauceLabs
│   ├── lambdatest.mdx                         LambdaTest
│   ├── marathon.mdx                           Marathon
│   ├── allure.mdx                             Allure
│   │   — Tooling and AI —
│   ├── vs-code-extension.mdx                  VS Code extension
│   ├── devtools-extension.mdx                 DevTools extension
│   ├── mcp.mdx                                MCP server
│   ├── agent-skills.mdx                       Agent skills
│   │   — Concepts —
│   └── tap-pump-scroll.mdx                    How tap, pump and scrollTo work
│
├── reference/                                 TAB: Reference
│   ├── index.mdx                              Reference
│   │   — CLI —
│   ├── cli/                                   CLI (open by default)
│   │   ├── index.mdx                          Commands and global flags
│   │   ├── develop.mdx                        develop
│   │   ├── test.mdx                           test
│   │   ├── build.mdx                          build
│   │   ├── test-without-building.mdx          test-without-building
│   │   ├── doctor.mdx                         doctor
│   │   ├── update.mdx                         update
│   │   └── devices.mdx                        devices
│   │   — Project —
│   ├── configuration.mdx                      Configuration
│   ├── compatibility-table.mdx                Compatibility table
│   ├── feature-parity.mdx                     Feature parity
│   ├── cheatsheet.mdx                         Cheat sheet
│   │   — Troubleshooting —
│   ├── troubleshooting.mdx                    Troubleshooting
│   │   — Upgrading Patrol —
│   ├── upgrading/                             Upgrading Patrol
│   │   ├── index.mdx                          Upgrading Patrol
│   │   │   — Migration guides —
│   │   ├── v4.mdx                             v4
│   │   ├── native-to-platform.mdx             native → platform
│   │   ├── spm.mdx                            SPM
│   │   ├── v3.mdx                             v3
│   │   ├── v2.mdx                             v2
│   │   │   — Release notes —
│   │   ├── mcp-release.mdx                    MCP release
│   │   ├── logs-release.mdx                   Logs release
│   │   └── patrol-finders-release.mdx         patrol_finders release
│   │   — Archive —
│   ├── archive/                               Archive
│   │   ├── index.mdx                          Archive
│   │   ├── android-setup-groovy.mdx           Android setup (Groovy)
│   │   └── native2.mdx                        Native Automation 2.0 (native2)
│   │   — API docs —
│   └── (external) patrol API (pub.dev), patrol_finders API (pub.dev)
│
└── support/                                   TAB: Support & Services
    ├── index.mdx                              Get help
    ├── services.mdx                           Services
    ├── articles.mdx                           Articles and resources
    └── (external) GitHub issues
```
