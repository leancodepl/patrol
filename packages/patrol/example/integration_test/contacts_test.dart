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

  late String firstContact;
  late String secondContact;

  patrol('creates new contact', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);
    await $.native.tap(Selector(text: 'All Contacts'), appId: contactsAppId);

    firstContact = await _createNewContact($);
    secondContact = await _createNewContact($);
  });

  patrol('opens created contacts', ($) async {
    await $.native.tap(Selector(text: firstContact), appId: contactsAppId);
    await $.native.pressHome();
    await $.native.tap(Selector(text: secondContact), appId: contactsAppId);
    await $.native.pressHome();
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
    await $.native.tap(Selector(text: 'Contacts'), appId: contactsAppId);
  } else {
    await $.native.pressBack();
  }
}
