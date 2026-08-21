package pl.leancode.patrol

import org.junit.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PatrolGeneratedTestsDetectionTest {
    @Test
    fun `host class is superseded when a generated class sits next to it`() {
        assertTrue(
            PatrolJUnitRunner.isSupersededByGeneratedTests(
                "pl.leancode.patrol.generated.MainActivityTest",
            ),
        )
    }

    @Test
    fun `host class is left alone when no generated class was built`() {
        assertFalse(
            PatrolJUnitRunner.isSupersededByGeneratedTests(
                "pl.leancode.patrol.runtimeonly.MainActivityTest",
            ),
        )
    }

    @Test
    fun `generated class never supersedes itself`() {
        assertFalse(
            PatrolJUnitRunner.isSupersededByGeneratedTests(
                "pl.leancode.patrol.generated.PatrolGeneratedTests",
            ),
        )
    }

    @Test
    fun `class outside any package is left alone`() {
        assertFalse(PatrolJUnitRunner.isSupersededByGeneratedTests("MainActivityTest"))
    }
}
