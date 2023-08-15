package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.Contracts.DartGroupEntry
import pl.leancode.patrol.contracts.DartGroupEntryKt
import pl.leancode.patrol.contracts.copy
import pl.leancode.patrol.contracts.dartGroupEntry
import kotlin.test.assertContentEquals

fun dartTestGroup(block: DartGroupEntryKt.Dsl.() -> Unit): DartGroupEntry {
    return dartGroupEntry(block).copy { type = DartGroupEntry.GroupEntryType.GROUP }
}

fun dartTestCase(block: DartGroupEntryKt.Dsl.() -> Unit): DartGroupEntry {
    return dartGroupEntry(block).copy { type = DartGroupEntry.GroupEntryType.TEST }
}

class DartTestGroupExtensionsTest {

    @Test
    fun `listTestsFlat() handles simple hierarchy`() {
        // given
        val dartTestGroup = dartTestGroup {
            name = ""
            entries += listOf(
                dartTestGroup {
                    name = "example_test"
                    entries += listOf(dartTestCase { name = "increments counter, exits the app, and comes back" })
                },
                dartTestGroup {
                    name = "open_app_test"
                    entries += listOf(dartTestCase { name = "open maps" })
                },
                dartTestGroup {
                    name = "webview_test"
                    entries += listOf(dartTestCase { name = "interacts with the LeanCode website in a webview" })
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
        val exampleTest = dartTestGroup {
            name = "example_test"
            entries += listOf(
                dartTestCase { name = "the first test" },
                dartTestGroup {
                    name = "top level group in file"
                    entries += listOf(
                        dartTestGroup {
                            name = "alpha"
                            entries += listOf(
                                dartTestCase { name = "first" },
                                dartTestCase { name = "second" },
                            )
                        },
                        dartTestCase { name = "test between groups" },
                        dartTestGroup {
                            name = "bravo"
                            entries += listOf(
                                dartTestCase { name = "first" },
                                dartTestCase { name = "second" },
                            )
                        },
                    )
                }
            )
        }

        val openAppTest = dartTestGroup {
            name = "open_app_test"
            entries += listOf(
                dartTestCase { name = "open maps" },
                dartTestCase { name = "open browser" },
            )
        }

        val rootDartTestGroup = dartTestGroup {
            name = ""
            entries += listOf(exampleTest, openAppTest)
        }

        // when
        val dartTestFiles = rootDartTestGroup.listTestsFlat()

        // then
        assertContentEquals(
            listOf(
                // example_test
                dartTestCase { name = "example_test the first test" },
                dartTestCase { name = "example_test top level group in file alpha first" },
                dartTestCase { name = "example_test top level group in file alpha second" },
                dartTestCase { name = "example_test top level group in file test between groups" },
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
