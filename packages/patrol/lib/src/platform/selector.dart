import 'package:patrol/src/platform/contracts/contracts.dart' as contracts;

abstract interface class CompoundSelector {
  contracts.AndroidSelector get android;
  contracts.IOSSelector get ios;
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
}

class AndroidSelector extends contracts.AndroidSelector
    implements CompoundSelector {
  @override
  contracts.AndroidSelector get android => this;

  @override
  contracts.IOSSelector get ios =>
      throw UnsupportedError('IOS selector is not supported');
}

class IOSSelector extends contracts.IOSSelector implements CompoundSelector {
  @override
  contracts.AndroidSelector get android =>
      throw UnsupportedError('Android selector is not supported');

  @override
  contracts.IOSSelector get ios => this;
}
