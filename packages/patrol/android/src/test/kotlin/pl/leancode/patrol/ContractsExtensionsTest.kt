package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.dartTestCase
import pl.leancode.patrol.contracts.dartTestGroup
import kotlin.test.assertContentEquals

// TODO: Make sure these tests are run on CI

class DartTestGroupExtensionsTest {
    @Test
    fun `listDartFilesFlat() lists the Dart test files in the integration_test directory`() {

        // ── permissions
        // ├── permissions_location_test.dart
        // └── permissions_many_test.dart
        // ── sign_in
        // ├── sign_in_email_test.dart
        // ├── sign_in_facebook_test.dart
        // └── sign_in_google_test.dart
        // ── example_test.dart
        val dartTestGroup = dartTestGroup {
            name = "root"
            groups += listOf(
                dartTestGroup {
                    name = "permissions"
                    groups += listOf(
                        dartTestGroup {
                            name = "permissions_location_test.dart"
                            tests += listOf(
                                dartTestCase {
                                    name = "accepts location permission"
                                }
                            )
                        },
                        dartTestGroup {
                            name = "permissions_many_test.dart"
                            tests += listOf(
                                dartTestCase {
                                    name = "accepts various permissions"
                                }
                            )
                        }
                    )
                },
                dartTestGroup {
                    name = "sign_in"
                    groups += listOf(
                        dartTestGroup {
                            name = "sign_in_email_test.dart"
                            tests += listOf(
                                dartTestCase {
                                    name = "signs in with email"
                                }
                            )
                        },
                        dartTestGroup {
                            name = "sign_in_facebook_test.dart"
                            tests += listOf(
                                dartTestCase {
                                    name = "signs in with facebook"
                                }
                            )
                        },
                        dartTestGroup {
                            name = "sign_in_google_test.dart"
                            tests += listOf(
                                dartTestCase {
                                    name = "signs in with google"
                                }
                            )
                        }
                    )
                },
                dartTestGroup {
                    name = "example_test.dart"
                    tests += listOf(
                        dartTestCase {
                            name = "some example test"
                        }
                    )
                }
            )
        }

        val dartTestFiles = dartTestGroup.listFlatDartFiles()

        println(dartTestFiles)

        assertContentEquals(
            listOf(
                "permissions_location_test.dart",
                "permissions_many_test.dart",
                "sign_in_email_test.dart",
                "sign_in_facebook_test.dart",
                "sign_in_google_test.dart",
                "example_test.dart"
            ),
            dartTestFiles,
        )
    }
}
