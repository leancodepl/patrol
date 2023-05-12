package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.dartTestGroup
import kotlin.test.assertContentEquals

// TODO: Make sure these tests are run on CI

class DartTestGroupExtensionsTest {
    @Test
    fun `listDartFilesFlat() litmus test`() {
        // given
        val dartTestGroup = dartTestGroup {
            name = "root"
            groups += listOf(
                dartTestGroup {
                    name = "example_test"
                },
                dartTestGroup {
                    name = "example.example_test"
                },
            )
        }

        // when
        val dartTestFiles = dartTestGroup.listFlatDartFiles()

        // then
        assertContentEquals(
            dartTestFiles,
            listOf(
                "example_test",
                "example.example_test",
            ),
        )
    }
}
