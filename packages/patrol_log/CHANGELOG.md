## 0.4.0

- Bump `custom_lint` to `0.7.0` and `leancode_lint` to `14.3.0`. (#2574)
- Format the test duration to show it in minutes and hours instead of seconds. (#2599)
- Fix gray text color in the terminal. (#2606)
- Add support for reading logs on iOS devices in release. (#2569)

## 0.3.0

- Remove `exception` from `StepEntry`. When it was too long, it caused crash because of badly formed JSON. (#2481)

## 0.2.2

- Don't pass `ConfigEntry` on start, if it's empty. (#2466)

## 0.2.1

- Fix skipping first word in started TestEntry. (#2433)

## 0.2.0

- Fix report path when path contain spaces. (#2426)
- Fix path to the test file on the failed test list in summary. (#2426)
- Add `ConfigEntry`. (#2426)

## 0.1.0

- Add option to not clear test steps.
- Display test path only in finished test logs.

## 0.0.1+2

- Remove flutter from dependencies.

## 0.0.1+1

- Reset step counter in develop.

## 0.0.1

- Initial release as a standalone package.
