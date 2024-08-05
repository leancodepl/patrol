package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.Contracts.DartGroupEntry
import pl.leancode.patrol.contracts.Contracts.GroupEntryType
import kotlin.test.assertContentEquals

fun dartTestGroup(
    name: String,
    entries: List<DartGroupEntry>,
): DartGroupEntry {
    return DartGroupEntry(name, GroupEntryType.group, entries, false, listOf<String>())
}

fun dartTestCase(name: String): DartGroupEntry {
    return DartGroupEntry(name, GroupEntryType.test, listOf(), false, listOf<String>())
}

class DartTestGroupExtensionsTest {
    @Test
    fun `listTestsFlat() handles simple hierarchy`() {
        // given
        val dartTestGroup = dartTestGroup(
            "",
            listOf(
                dartTestGroup(
                    "example_test",
                    listOf(dartTestCase("increments counter, exits the app, and comes back")),
                ),
                dartTestGroup(
                    "open_app_test",
                    listOf(dartTestCase("open maps")),
                ),
                dartTestGroup(
                    "webview_test",
                    listOf(dartTestCase("interacts with the LeanCode website in a webview")),
                ),
            ),
        )

        // when
        val dartTests = dartTestGroup.listTestsFlat()

        // then
        assertContentEquals(
            listOf(
                dartTestCase("example_test increments counter, exits the app, and comes back"),
                dartTestCase("open_app_test open maps"),
                dartTestCase("webview_test interacts with the LeanCode website in a webview"),
            ),
            dartTests,
        )
    }

    @Test
    fun `listTestsFlat() handles nested hierarchy`() {
        // given
        val exampleTest = dartTestGroup(
            "example_test",
            listOf(
                dartTestCase("the first test"),
                dartTestGroup(
                    "top level group in file",
                    listOf(
                        dartTestGroup(
                            "alpha",
                            listOf(
                                dartTestCase("first"),
                                dartTestCase("second"),
                            ),
                        ),
                        dartTestCase("test between groups"),
                        dartTestGroup(
                            "bravo",
                            listOf(
                                dartTestCase("first"),
                                dartTestCase("second"),
                            ),
                        ),
                    ),
                ),
            ),
        )

        val openAppTest = dartTestGroup(
                "open_app_test",
                listOf(
                    dartTestCase("open maps"),
                    dartTestCase("open browser"),
                ),
            )

        val rootDartTestGroup = dartTestGroup("", listOf(exampleTest, openAppTest))

        // when
        val dartTests = rootDartTestGroup.listTestsFlat()

        // then
        assertContentEquals(
            listOf(
                // example_test
                dartTestCase("example_test the first test"),
                dartTestCase("example_test top level group in file alpha first"),
                dartTestCase("example_test top level group in file alpha second"),
                dartTestCase("example_test top level group in file test between groups"),
                dartTestCase("example_test top level group in file bravo first"),
                dartTestCase("example_test top level group in file bravo second"),
                // open_app_test
                dartTestCase("open_app_test open maps"),
                dartTestCase("open_app_test open browser"),
            ),
            dartTests,
        )
    }
}
