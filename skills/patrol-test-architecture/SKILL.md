---
name: patrol-test-architecture
description: Add-on to patrol-write-test for Patrol test suites built on LeanCode's recommended architecture — Modules, System, and ApiClients — with per-feature keys.dart files. Use together with patrol-write-test when the project's Patrol tests already follow this architecture (e.g. a `patrol_test/modules/` directory and a `testApp` wrapper), or when the user asks to introduce it or to organize test code into modules.
---

This skill builds on **patrol-write-test**: follow it for the order of actions, Patrol MCP usage, Patrol test rules and test keys, and apply the changes below on top. Where the two differ, this skill wins.

# Changes to the order of actions

- Start by reading the key files directly (modules aggregator, test wrapper, main keys.dart, and the specific app feature files for the scenario). These are known paths — don't search for them, open them directly
- Look for functions to reuse or adjust in the existing modules
- While writing the test, still write patrol actions directly in the test file — do not create new methods in modules yet
- After full test passes, reorganize new code into existing/new modules instead of plain reusable functions. This is mandatory — the test file must only call module methods, not use Patrol APIs directly

# Patrol Test Architecture

## Structure

- Use custom `testApp` wrapper for all tests
- Each test file should contain only ONE test
- Organize tests using `Modules`, `System`, and `ApiClients` pattern
- Each module represents a feature from user perspective (eg. Auth, Home screen, Downloads, Player)
- System is a class for native interactions, specifically for actions that we need to perform by using $.platform that are not part of our app, eg. enabling airplane mode to test offline mode. Do not put methods here unless they don't fit any module of the app
- ApiClients - a class aggregating api clients for api communication. There will be separate clients for different apis we need to communicate with - eg. email server for testing, our test backend, or some third-party services

## Method organization in modules

- Do not write comments in all methods, use descriptive names instead
- Split long methods in modules when the method is hard to read and navigate due to its length and it represents multiple logical steps that can be descriptively named
- If there is a series of steps which is reused in many tests as a whole (e.g., long onboarding flow) create a wrapper method in the module which will call private methods for each step

# Test Keys

On top of the test-key rules in patrol-write-test, keys live in per-feature keys.dart files aggregated by a main `Keys` class:

- Create new keys.dart files if needed
- Always have a maximum of one keys.dart file per feature directory, but the file can contain multiple classes
- ALWAYS create keys.dart to store keys for the feature/widget they belong to, NOT in the main lib directory
- Add imports for keys.dart files
- Update main keys.dart aggregator
- The main `Keys` class in `lib/keys.dart` should only import and aggregate keys from feature-specific keys.dart files
- ALWAYS assign keys using this exact pattern: `key: keys.feature.widgetName` (unless you are using parameterized keys)
- Group related keys in a class named after the screen (e.g. `HomeKeys`). Use a private subclass of `ValueKey<String>` to prefix all key values with the page or widget name
- For common widgets store them in WidgetKeys class. File containing this class should be placed in the directory that the common widget is defined
- For widgets located in separate package (e.g. widgetbook) follow this pattern: in `widgetbook` directory create `keys.dart` file with `WidgetKeys` class. Those keys are assigned with `widgetKeys.tile`. Then, in keys.dart lib/ add it to the list of pages with `final widgetKeys = ds.widgetKeys;` (ds being the imported package, e.g. `import 'package:common_ui/widgets/keys.dart' as ds;`)

**Steps to assign a key to a widget:**

1. Identify widget that is needed for testing
2. Create key assignment: `key: keys.feature.widgetName`
3. Define key in keys.dart file
4. Verify key is assigned to widget

**File Structure Examples:**

Feature-specific keys:

```
lib/features/home/keys.dart
lib/features/profile/keys.dart
lib/features/auth/keys.dart
lib/common/widgets/keys.dart
```

Main keys aggregator:

```
lib/keys.dart (imports and aggregates all feature keys)
```

**Examples**

Feature-specific keys.dart:

```dart
// lib/features/home/keys.dart
import 'package:flutter/widgets.dart';

class _HomeKey extends ValueKey<String> {
  const _HomeKey(String value) : super('home_$value');
}
class HomeKeys {
  final menuIconButton = const _HomeKey('menuIconButton');
  _HomeKey navbarItem(String label) => _HomeKey('navbarItem_$label');
}
```

Main keys aggregator:

```dart
// lib/keys.dart
import 'common/widgets/keys.dart';
import 'features/home/keys.dart';
import 'features/profile/keys.dart';

final keys = Keys();

class Keys {
   final home = HomeKeys();
   final profile = ProfileKeys();
   final widgets = WidgetKeys();
}
```

Grouping keys:
/lib/features/product/keys.dart

```dart
import 'package:flutter/widgets.dart';

class _ProductPageKey extends ValueKey<String> {
  const _ProductPageKey(String value) : super('productPage_$value');
}
class ProductPageKeys {
  final menuIconButton = const _ProductPageKey('menuIconButton');
  final productImage = const _ProductPageKey('productImage');
  final productName = const _ProductPageKey('productName');
}
class _ProductConnectingPageKey extends ValueKey<String> {
  const _ProductConnectingPageKey(String value)
    : super('productConnectingPage_$value');
}
class ProductConnectingPageKeys {
  final productImage = const _ProductConnectingPageKey('productImage');
  final productName = const _ProductConnectingPageKey('productName');
}
```

Common widgets:
/lib/common/widgets/keys.dart

```dart
import 'package:flutter/widgets.dart';

class _WidgetKey extends ValueKey<String> {
  const _WidgetKey(String value) : super('widget_$value');
}
class WidgetKeys {
  final addButton = const _WidgetKey('addButton');
  _WidgetKey assetRow(String coinTitle) => _WidgetKey('assetRow_$coinTitle');
  _WidgetKey assetSlider(SelectAssetType type) =>
      _WidgetKey('assetSlider_$type');
  final cancelButton = const _WidgetKey('cancelButton');
  final pickCurrencyButton = const _WidgetKey('pickCurrencyButton');
  final saveButton = const _WidgetKey('saveButton');
  final searchBar = const _WidgetKey('searchBar');
  final topBarHeaderMiddleText = const _WidgetKey('topBarHeaderMiddleText');
}

```

External packages:
widgetbook/keys.dart:

```dart
import 'package:flutter/widgets.dart';
final widgetKeys = WidgetBookKeys();
class _WidgetBookKey extends ValueKey<String> {
  const _WidgetBookKey(String value) : super('widgetBook_$value');
}
class WidgetBookKeys {
  final tile = const _WidgetBookKey('tile');
}

```

Importing keys from external packages to main lib/keys.dart:

```dart
import 'package:common_ui/widgets/keys.dart' as ds;
final keys = Keys();
class Keys {
  final widgetKeys = ds.widgetKeys;
}
```

Example of assigning a parameterized key to a widget:

```dart
enum SizeDTO {
  small,
  medium,
  large,
}

class PickSizeWidget extends StatelessWidget {
  Widget _sizeButton(SizeDTO size) {
    return _Button(
      key: keys.pickSize.sizeButton(size),
      value: size,
      currentValue: value,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sizeButton(SizeDTO.small),
        _sizeButton(SizeDTO.medium),
        _sizeButton(SizeDTO.large),
      ].spaced(24),
    );
  }
}
```

keys.dart:

```dart
  _PickSizeKey sizeButton(SizeDTO size) => _PickSizeKey('sizeButton_${size.name}');
```

# Code Examples

## Module Structure

Feature module example

patrol_test/modules/home.dart

```dart
import 'package:patrol/patrol.dart';
import 'module.dart';

final class Home extends Module {
  Home(super.$);

  Future<void> navigateToSettings() async {
    await $(keys.home.settingsButton).scrollTo().tap();
  }

  Future<void> searchForItem(String searchPhrase) async {
    await $(keys.home.searchButton).scrollTo().tap();
    await $(keys.home.searchInput).enterText(searchPhrase);
    await $(keys.home.searchSubmitButton).tap();
  }
}
```

Modules aggregator

patrol_test/modules/modules.dart

```dart
final class Modules {
  Modules(this._$);
  final PatrolIntegrationTester _$;

  late final home = Home(_$);
  late final auth = Auth(_$);
}
```

## System Class

patrol_test/modules/system.dart

```dart
final class System extends PlatformAutomator {
  System({required super.config});

  Future<void> checkIfNativePlayerIsVisible() async {
    // Implementation
  }
}
```

## ApiClients Class

patrol_test/modules/api_clients.dart

```dart
final class ApiClients {
  final backend = BackendClient();
  final mailpitClient = MailpitClient();
}
```

## Complete Test Example

```dart
testApp('Download a chapter and play it offline', ($, modules, system, apiClients) async {
    await modules.auth.getAuthToken();
    await apiClients.backend.addFavourites();
    await openApp($);
    await modules.home.goToOldTestament();
    await modules.testament.expandBook(bookName: 'Book of Revelation');
    await modules.testament.chooseChapterOfBook(
      bookName: 'Book of Revelation',
      chapterIndex: 0,
    );
    await modules.player.expandChapters();
    await modules.player.downloadChapter(chapterIndex: 9);
    await modules.player.waitUntilDownloaded();
    // usage of a method from $.platform Equivalent of await $.platform.mobile.enableAirplaneMode();
    await system.enableAirplaneMode();
    await modules.player.rollDownChapters();
    await modules.player.closeChapterPlayer();
    await modules.testament.closeTestament();
    await modules.bottomNavigation.goToLibrary();
    await modules.library.goToDownloads();
    await modules.downloads.expandOldTestament();
    await modules.downloads.goToBook(bookName: 'Book of Revelation');
    await modules.player.checkIfChapterIsCorrect(chapterIndex: 0);
    await modules.player.playCurrentTrack();
    // usage of our method, which calls many methods from $.platform
    await system.checkIfNativePlayerIsVisible();
  });
```
