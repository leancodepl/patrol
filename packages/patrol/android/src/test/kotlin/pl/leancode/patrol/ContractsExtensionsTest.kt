package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.dartTestCase
import pl.leancode.patrol.contracts.dartTestGroup
import kotlin.test.assertContentEquals

// TODO: Make sure these tests are run on CI

class DartTestGroupExtensionsTest {

    @Test
    fun `listTestsFlat() handles simple hierarchy`() {
        // given
        val dartTestGroup = dartTestGroup {
            name = ""
            groups += listOf(
                dartTestGroup {
                    name = "example_test"
                    tests += listOf(dartTestCase { name = "increments counter, exits the app, and comes back" })
                },
                dartTestGroup {
                    name = "open_app_test"
                    tests += listOf(dartTestCase { name = "open maps" })
                },
                dartTestGroup {
                    name = "webview_test"
                    tests += listOf(dartTestCase { name = "interacts with the LeanCode website in a webview" })
                }
            )
        }

        // when
        val dartTestFiles = dartTestGroup.listTestsFlat()

        // then
        assertContentEquals(
            listOf(
                dartTestCase { name = "example_test increments counter, exits the app, and comes back" },
                dartTestCase { name = "open_app_test open maps" },
                dartTestCase { name = "webview_test interacts with the LeanCode website in a webview" },
            ),
            dartTestFiles,
        )
    }

    @Test
    fun `listTestsFlat() handles nested hierarchy`() {
        // given
        val dartTestGroup = dartTestGroup {
            name = ""
            groups += listOf(
                dartTestGroup {
                    name = "example_test"
                    groups += listOf(
                        dartTestGroup {
                            name = "top level group in file"
                            groups += listOf(
                                dartTestGroup {
                                    name = "alpha"
                                    tests += listOf(
                                        dartTestCase { name = "first" },
                                        dartTestCase { name = "second" },
                                    )
                                },
                                dartTestGroup {
                                    name = "bravo"
                                    tests += listOf(
                                        dartTestCase { name = "first" },
                                        dartTestCase { name = "second" },
                                    )
                                },
                            )
                        }
                    )
                },
                dartTestGroup {
                    name = "open_app_test"
                    tests += listOf(
                        dartTestCase { name = "open maps" },
                        dartTestCase { name = "open browser" },
                    )
                },
            )
        }

        // when
        val dartTestFiles = dartTestGroup.listTestsFlat()

        // then
        assertContentEquals(
            listOf(
                // example_test
                dartTestCase { name = "example_test top level group in file alpha first" },
                dartTestCase { name = "example_test top level group in file alpha second" },
                dartTestCase { name = "example_test top level group in file bravo first" },
                dartTestCase { name = "example_test top level group in file bravo second" },
                // open_app_test
                dartTestCase { name = "open_app_test open maps" },
                dartTestCase { name = "open_app_test open browser" },
            ),
            dartTestFiles,
        )
    }
}
