import 'package:patrol/src/platform/contracts/contracts.dart' as contracts;
import 'package:patrol/src/platform/web/web_selector.dart' as web_selector;

abstract interface class CompoundSelector {
  contracts.AndroidSelector get android;
  contracts.IOSSelector get ios;
  web_selector.WebSelector get web;
}

class Selector implements CompoundSelector {
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

  String? text;
  String? textStartsWith;
  String? textContains;
  String? className;
  String? contentDescription;
  String? contentDescriptionStartsWith;
  String? contentDescriptionContains;
  String? resourceId;
  int? instance;
  bool? enabled;
  bool? focused;
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

class AndroidSelector extends contracts.AndroidSelector
    implements CompoundSelector {
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

class IOSSelector extends contracts.IOSSelector implements CompoundSelector {
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

class WebSelector extends web_selector.WebSelector implements CompoundSelector {
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
