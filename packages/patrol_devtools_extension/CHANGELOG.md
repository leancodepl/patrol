## Unreleased

- Regenerate API contracts for the new Android `ConfigureRequest` accessibility flag. (#3227)
- Render the web view hierarchy (the page's DOM) when connected to a Flutter web app, alongside the existing Android and iOS trees. Nodes are labelled by test id, DOM id or accessible label so a Flutter web tree doesn't read as a wall of identical `flt-semantics` entries, and the details panel shows role, aria-label, test id, text, visibility and bounds.

## 0.4.1

- Bump `equatable` to `^2.1.0` and migrate API contract types from deprecated `EquatableMixin` to `with Equatable`.

## 0.4.0

- Bump `leancode_lint` to `17.0.0`. (#2690)
- Bump minimum Dart SDK to version 3.8.0. (#2690)

## 0.3.0

- Bump `custom_lint` to `0.7.0` and `leancode_lint` to `14.3.0`. (#2574)
- Bump `vm_service` dependency to `15.0.0` (#2649)
- Bump min Flutter SDK to 3.32.0 (#2649)

## 0.2.1

- Make details view panel scrollable when content overflows (#2358)
- Copy selector arguments with single quote (#2358)
- Bump min Flutter SDK to 3.24.0 and Dart SDK to 3.5.0 (#2371)
