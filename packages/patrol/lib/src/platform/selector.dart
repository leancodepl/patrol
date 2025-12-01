import 'package:patrol/src/platform/contracts/contracts.dart' as contracts;
import 'package:patrol/src/platform/web/web_selector.dart' as web_selector;

/// A selector that can be used across platforms (Android, iOS, and Web).
abstract interface class CompoundSelector {
  /// Returns the Android-specific selector.
  contracts.AndroidSelector get android;

  /// Returns the iOS-specific selector.
  contracts.IOSSelector get ios;

  /// Returns the Web-specific selector.
  web_selector.WebSelector get web;
}

/// A cross-platform selector for finding UI elements.
class Selector implements CompoundSelector {
  /// Creates a new [Selector].
  Selector({
    this.text,
    this.textStartsWith,
    this.textContains,
    this.className,
    this.contentDescription,
    this.contentDescriptionStartsWith,
    this.contentDescriptionContains,
    this.resourceId,
    this.instance,
    this.enabled,
    this.focused,
    this.pkg,
  });

  /// The exact text to match.
  String? text;

  /// Match text that starts with this string.
  String? textStartsWith;

  /// Match text that contains this string.
  String? textContains;

  /// The class name of the element.
  String? className;

  /// The content description of the element.
  String? contentDescription;

  /// Match content description that starts with this string.
  String? contentDescriptionStartsWith;

  /// Match content description that contains this string.
  String? contentDescriptionContains;

  /// The resource ID of the element.
  String? resourceId;

  /// The instance index when multiple elements match.
  int? instance;

  /// Whether the element is enabled.
  bool? enabled;

  /// Whether the element is focused.
  bool? focused;

  /// The package name of the application.
  String? pkg;

  @override
  contracts.AndroidSelector get android => contracts.AndroidSelector(
    text: text,
    textStartsWith: textStartsWith,
    textContains: textContains,
    className: className,
    contentDescription: contentDescription,
    contentDescriptionStartsWith: contentDescriptionStartsWith,
    contentDescriptionContains: contentDescriptionContains,
    resourceName: resourceId,
    instance: instance,
    isEnabled: enabled,
    isFocused: focused,
    applicationPackage: pkg,
  );

  @override
  contracts.IOSSelector get ios => contracts.IOSSelector(
    text: text,
    textStartsWith: textStartsWith,
    textContains: textContains,
    identifier: resourceId,
  );

  @override
  web_selector.WebSelector get web =>
      web_selector.WebSelector(text: text, cssOrXpath: className);
}

/// A compound selector that behaves like NativeSelector, allowing platform-specific
/// iOS and Android selectors to be specified separately.
///
/// This is useful when iOS and Android require different selector values or types.
class PlatformCompoundSelector implements CompoundSelector {
  /// Creates a new [PlatformCompoundSelector].
  PlatformCompoundSelector({
    IOSSelector? ios,
    AndroidSelector? android,
    WebSelector? web,
  }) : _ios = ios,
       _android = android,
       _web = web;

  final IOSSelector? _ios;
  final AndroidSelector? _android;
  final WebSelector? _web;

  @override
  IOSSelector get ios =>
      _ios ?? (throw UnsupportedError('iOS selector not provided'));

  @override
  AndroidSelector get android =>
      _android ?? (throw UnsupportedError('Android selector not provided'));

  @override
  WebSelector get web =>
      _web ?? (throw UnsupportedError('Web selector not provided'));
}

/// An Android-specific selector for finding UI elements.
class AndroidSelector extends contracts.AndroidSelector
    implements CompoundSelector {
  /// Creates a new [AndroidSelector].
  AndroidSelector({
    super.className,
    super.isCheckable,
    super.isChecked,
    super.isClickable,
    super.isEnabled,
    super.isFocusable,
    super.isFocused,
    super.isLongClickable,
    super.isScrollable,
    super.isSelected,
    super.applicationPackage,
    super.contentDescription,
    super.contentDescriptionStartsWith,
    super.contentDescriptionContains,
    super.text,
    super.textStartsWith,
    super.textContains,
    super.resourceName,
    super.instance,
  });
  @override
  contracts.AndroidSelector get android => this;

  @override
  contracts.IOSSelector get ios =>
      throw UnsupportedError('IOS selector is not supported');

  @override
  web_selector.WebSelector get web =>
      throw UnsupportedError('Web selector is not supported');
}

/// An iOS-specific selector for finding UI elements.
class IOSSelector extends contracts.IOSSelector implements CompoundSelector {
  /// Creates a new [IOSSelector].
  IOSSelector({
    super.value,
    super.instance,
    super.elementType,
    super.identifier,
    super.text,
    super.textStartsWith,
    super.textContains,
    super.label,
    super.labelStartsWith,
    super.labelContains,
    super.title,
    super.titleStartsWith,
    super.titleContains,
    super.hasFocus,
    super.isEnabled,
    super.isSelected,
    super.placeholderValue,
    super.placeholderValueStartsWith,
    super.placeholderValueContains,
  });
  @override
  contracts.AndroidSelector get android =>
      throw UnsupportedError('Android selector is not supported');

  @override
  contracts.IOSSelector get ios => this;

  @override
  web_selector.WebSelector get web =>
      throw UnsupportedError('Web selector is not supported');
}

/// A Web-specific selector for finding UI elements.
class WebSelector extends web_selector.WebSelector implements CompoundSelector {
  /// Creates a new [WebSelector].
  WebSelector({
    super.role,
    super.label,
    super.placeholder,
    super.text,
    super.altText,
    super.title,
    super.testId,
    super.cssOrXpath,
  });
  @override
  contracts.AndroidSelector get android =>
      throw UnsupportedError('Android selector is not supported');

  @override
  contracts.IOSSelector get ios =>
      throw UnsupportedError('IOS selector is not supported');

  @override
  web_selector.WebSelector get web => this;
}
