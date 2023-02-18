import 'dart:io' show Platform;

import 'package:faker/faker.dart';

import 'common.dart';

late String contactsAppId;

Future<void> main() async {
  if (Platform.isIOS) {
    contactsAppId = 'com.apple.MobileAddressBook';
  } else if (Platform.isAndroid) {
    contactsAppId = 'com.google.android.contacts';
  }

  late String firstContact;
  late String secondContact;

  patrol('creates new contact', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);

    if (Platform.isIOS) {
      await $.native.tap(Selector(text: 'All iPhone'), appId: contactsAppId);
    }

    firstContact = await _createNewContact($);
    secondContact = await _createNewContact($);
  });

  patrol('opens created contacts', ($) async {
    await $.native.openApp();
    await $.pumpWidgetAndSettle(ExampleApp());
    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);

    await $.native.tap(Selector(text: firstContact), appId: contactsAppId);
    await _goBack($);
    await $.native.tap(Selector(text: secondContact), appId: contactsAppId);
    await _goBack($);
  });

  patrol('creates two contacts with the same name', ($) async {
    await $.native.openApp();
    await $.pumpWidgetAndSettle(ExampleApp());
    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);

    final first = await _createNewContact(
      $,
      firstName: 'Charlie',
      lastName: 'Root',
    );
    final second = await _createNewContact(
      $,
      firstName: 'Charlie',
      lastName: 'Root',
    );

    await $.native.tap(
      Selector(text: first, instance: 0),
      appId: contactsAppId,
    );
    // TODO: Verify that first contact is shown

    await _goBack($);

    await $.native.tap(
      Selector(text: second, instance: 1),
      appId: contactsAppId,
    );
    // TODO: Verify that second contact is shown

    await _goBack($);
  });
}

/// Creates a new contact with random data.
///
/// Returns the first name and last name of the created contact.
Future<String> _createNewContact(
  PatrolTester $, {
  String? firstName,
  String? lastName,
}) async {
  if (Platform.isIOS) {
    return _createContactOnIOS($, firstName: firstName, lastName: lastName);
  } else if (Platform.isAndroid) {
    return _createContactOnAndroid($, firstName: firstName, lastName: lastName);
  }

  throw UnsupportedError('unsupported platform');
}

Future<String> _createContactOnIOS(
  PatrolTester $, {
  String? firstName,
  String? lastName,
}) async {
  firstName = firstName ?? faker.person.firstName();
  lastName = lastName ?? faker.person.lastName();
  final company = faker.company.name();
  final phoneNumber = faker.phoneNumber.us();
  final email = faker.internet.email();

  await $.native.tap(Selector(text: 'Add'), appId: contactsAppId);
  await $.native.enterTextByIndex(firstName, index: 0, appId: contactsAppId);
  await $.native.enterTextByIndex(lastName, index: 1, appId: contactsAppId);
  await $.native.enterTextByIndex(company, index: 2, appId: contactsAppId);

  await $.native.tap(Selector(text: 'add phone'), appId: contactsAppId);
  await $.native.enterText(
    Selector(text: 'Phone'),
    text: phoneNumber,
    appId: contactsAppId,
  );

  await $.native.tap(Selector(text: 'add email'), appId: contactsAppId);
  await $.native.enterText(
    Selector(text: 'Email'),
    text: email,
    appId: contactsAppId,
  );

  await $.native.tap(Selector(text: 'Done'), appId: contactsAppId);

  await _goBack($);

  return '$firstName $lastName';
}

Future<String> _createContactOnAndroid(
  PatrolTester $, {
  String? firstName,
  String? lastName,
}) async {
  firstName = firstName ?? faker.person.firstName();
  lastName = lastName ?? faker.person.lastName();
  final company = faker.company.name();
  final phoneNumber = faker.phoneNumber.us();
  final email = faker.internet.email();

  await $.native.tap(Selector(contentDescription: 'Create contact'));
  await $.native.enterTextByIndex(firstName, index: 0);
  await $.native.enterTextByIndex(lastName, index: 1);
  await $.native.enterTextByIndex(company, index: 2);
  await $.native.enterText(Selector(text: 'Phone'), text: phoneNumber);
  await $.native.enterText(Selector(text: 'Email'), text: email);
  await $.native.tap(Selector(text: 'Save'));

  await _goBack($);

  return '$firstName $lastName';
}

Future<void> _goBack(PatrolTester $) async {
  if (Platform.isIOS) {
    await $.native.tap(Selector(text: 'iPhone'), appId: contactsAppId);
  } else if (Platform.isAndroid) {
    await $.native.tap(Selector(contentDescription: 'Navigate up'));
  }
}
