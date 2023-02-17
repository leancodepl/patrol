import 'dart:io' show Platform;

import 'package:faker/faker.dart';

import 'common.dart';

late String contactsAppId;

Future<void> main() async {
  if (Platform.isIOS) {
    contactsAppId = 'com.apple.MobileAddressBook';
  } else if (Platform.isAndroid) {
    contactsAppId = 'com.android.contacts';
  }

  patrol('creates new contact', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);

    final name1 = await _createNewContact($);
    final name2 = await _createNewContact($);

    await $.native.tap(Selector(text: name1), appId: contactsAppId);
    // await _goBack($);
    // await $.native.tap(Selector(text: name2), appId: contactsAppId);
    // await _goBack($);
  });
}

/// Creates a new contact with random data.
///
/// Returns the first name and last name of the created contact.
Future<String> _createNewContact(PatrolTester $) async {
  final firstName = faker.person.firstName();
  final lastName = faker.person.lastName();
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

Future<void> _goBack(PatrolTester $) async {
  if (Platform.isIOS) {
    await $.native.tap(Selector(text: 'iPhone'), appId: contactsAppId);
  } else {
    await $.native.pressBack();
  }
}
