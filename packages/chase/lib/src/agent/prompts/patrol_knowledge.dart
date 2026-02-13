/// Complete Patrol API reference and best practices.
///
/// This encodes LeanCode's unique knowledge as the creators of Patrol.
const patrolKnowledgeBase = r'''
## Patrol Integration Testing Framework — Complete Reference

### Core Concepts

Patrol is a Flutter integration testing framework that provides:
1. **Custom finders** — concise widget finding via `$()` syntax
2. **Native automation** — interact with OS-level UI (permissions, notifications, settings)
3. **patrolTest()** — replacement for `testWidgets()` with auto-configuration

### Test Structure

```dart
import 'package:patrol/patrol.dart';
import 'package:my_app/main.dart' as app;

void main() {
  patrolTest('should display home screen', ($) async {
    app.main();
    await $.pumpAndSettle();

    // Test assertions using Patrol finders
    await $(Text('Welcome')).waitUntilVisible();
    expect($('Welcome'), findsOneWidget);
  });
}
```

### patrolTest() Configuration

```dart
patrolTest(
  'test description',
  config: PatrolTesterConfig(
    // Timeouts
    visibleTimeout: Duration(seconds: 10),
    existsTimeout: Duration(seconds: 10),
    settleTimeout: Duration(seconds: 10),
    // Platform behavior
    appName: 'My App',
    packageName: 'com.example.myapp',
    bundleId: 'com.example.myapp',
  ),
  nativeAutomation: true,  // Enable native automation
  ($) async {
    // test body
  },
);
```

### Custom Finders — $() Syntax

```dart
// Find by type
$(Text)                     // finds all Text widgets
$(ElevatedButton)           // finds all ElevatedButton widgets
$(MyCustomWidget)           // finds by custom widget type

// Find by text content
$('Login')                  // finds widget with text "Login"
$('Submit')                 // text matching

// Find by Key
$(Key('login_button'))      // finds by Key
$(#loginButton)             // finds by Symbol (alternative)

// Find by icon
$(Icons.add)                // finds Icon with Icons.add

// Chaining finders
$(ListTile).containing($('Item 1'))    // ListTile containing text
$(Column).$(Text)                       // Text widgets inside Column
$(MyCard).at(0)                         // First MyCard widget
$(MyCard).at(1)                         // Second MyCard widget

// Finder operations
await $(Text('Login')).tap()            // tap
await $(TextField).at(0).enterText('hello')  // enter text
await $(Text('Login')).waitUntilVisible()    // wait
await $(Text('Login')).waitUntilExists()     // wait for existence
await $('Login').scrollTo()                   // scroll until visible
```

### Native Automation ($.native)

```dart
// Permissions
await $.native.grantPermissionWhenInUse();
await $.native.grantPermissionOnlyThisTime();
await $.native.denyPermission();

// Notifications
await $.native.openNotifications();
await $.native.closeNotifications();
await $.native.tapOnNotificationByIndex(0);

// System navigation
await $.native.pressHome();
await $.native.pressBack();
await $.native.pressRecentApps();
await $.native.pressDoubleRecentApps();

// Settings
await $.native.openQuickSettings();
await $.native.enableWifi();
await $.native.disableWifi();
await $.native.enableBluetooth();
await $.native.disableBluetooth();
await $.native.enableCellular();
await $.native.disableCellular();
await $.native.enableDarkMode();
await $.native.disableDarkMode();

// Native views
await $.native.tap(Selector(text: 'Allow'));
await $.native.enterTextByIndex('search text', index: 0);
await $.native.swipe(
  from: Offset(0.5, 0.8),
  to: Offset(0.5, 0.2),
);

// WebViews and other native elements
await $.native.isPermissionDialogVisible();
```

### Scrolling

```dart
// Scroll within a scrollable widget
await $('Item 50').scrollTo();
await $('Item 50').scrollTo(
  view: $(CustomScrollView),
  scrollDirection: AxisDirection.down,
);

// Drag / swipe
await $(PageView).swipe(from: Offset(0.8, 0.5), to: Offset(0.2, 0.5));
```

### Waiting and Settling

```dart
// Wait for widget to appear
await $(Text('Loaded')).waitUntilVisible();
await $(Text('Loaded')).waitUntilExists();

// Pump and settle (wait for animations)
await $.pumpAndSettle();
await $.pump(Duration(seconds: 1));

// Pump widget (for starting the app)
await $.pumpWidgetAndSettle(
  MaterialApp(home: MyScreen()),
);
```

### Test App Startup Patterns

```dart
// Pattern 1: Using app.main()
import 'package:my_app/main.dart' as app;

patrolTest('test', ($) async {
  app.main();
  await $.pumpAndSettle();
});

// Pattern 2: Using pumpWidgetAndSettle for isolated tests
patrolTest('test', ($) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Scaffold(body: MyWidget()),
    ),
  );
});
```

### Common Patterns

```dart
// Login flow test
patrolTest('user can log in', ($) async {
  app.main();
  await $.pumpAndSettle();

  await $(TextField).at(0).enterText('user@example.com');
  await $(TextField).at(1).enterText('password123');
  await $('Login').tap();

  await $(Text('Welcome')).waitUntilVisible();
});

// Navigation test
patrolTest('navigates to settings', ($) async {
  app.main();
  await $.pumpAndSettle();

  await $(Icons.settings).tap();
  await $(Text('Settings')).waitUntilVisible();
});

// List interaction test
patrolTest('can select item from list', ($) async {
  app.main();
  await $.pumpAndSettle();

  await $('Item 5').scrollTo();
  await $('Item 5').tap();

  await $(Text('Item 5 Details')).waitUntilVisible();
});

// Form validation test
patrolTest('shows validation errors', ($) async {
  app.main();
  await $.pumpAndSettle();

  await $('Submit').tap();
  await $.pumpAndSettle();

  expect($('Required field'), findsWidgets);
});
```

### Important Rules

1. **ALWAYS** use `patrolTest()` — never `testWidgets()` or `test()`
2. **ALWAYS** import `package:patrol/patrol.dart`
3. **ALWAYS** call `await $.pumpAndSettle()` after `app.main()`
4. **ALWAYS** use `$()` custom finders instead of `find.`
5. **NEVER** use `tester.` — use `$` parameter instead
6. **ALWAYS** wait for widgets before interacting: `waitUntilVisible()` or `waitUntilExists()`
7. **ALWAYS** run `dart analyze` to validate generated tests
8. Test files must end with `_test.dart`
9. Use descriptive test names that explain the user scenario
10. Handle async operations with `await`
11. Group related tests in the same file
12. Use `$.native` only when testing platform-specific behavior
''';
