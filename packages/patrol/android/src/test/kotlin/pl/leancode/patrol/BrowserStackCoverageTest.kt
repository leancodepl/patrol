package pl.leancode.patrol

import kotlin.test.Test
import kotlin.test.assertEquals

class MergeLcovTest {
    @Test
    fun `keeps the highest hit count per line across sources`() {
        val a = "SF:package:app/a.dart\nDA:1,1\nDA:2,0\nLF:2\nLH:1\nend_of_record\n"
        val b = "SF:package:app/a.dart\nDA:1,5\nDA:2,3\nLF:2\nLH:2\nend_of_record\n"

        val merged = mergeLcov(listOf(a, b))

        assertEquals(
            "SF:package:app/a.dart\nDA:1,5\nDA:2,3\nLF:2\nLH:2\nend_of_record\n",
            merged
        )
    }

    @Test
    fun `unions files and lines from different sources`() {
        val a = "SF:package:app/a.dart\nDA:1,1\nLF:1\nLH:1\nend_of_record\n"
        val b = "SF:package:app/b.dart\nDA:7,0\nLF:1\nLH:0\nend_of_record\n"

        val merged = mergeLcov(listOf(a, b))

        assertEquals(
            "SF:package:app/a.dart\nDA:1,1\nLF:1\nLH:1\nend_of_record\n" +
                "SF:package:app/b.dart\nDA:7,0\nLF:1\nLH:0\nend_of_record\n",
            merged
        )
    }

    @Test
    fun `merging N identical snapshots stays the size of one`() {
        val snapshot = "SF:package:app/a.dart\nDA:1,1\nDA:2,1\nLF:2\nLH:2\nend_of_record\n"

        val merged = mergeLcov(List(50) { snapshot })

        assertEquals(snapshot, merged)
    }

    @Test
    fun `sorts lines numerically, not lexicographically`() {
        val source = "SF:package:app/a.dart\nDA:10,1\nDA:2,1\nDA:1,1\nend_of_record\n"

        val merged = mergeLcov(listOf(source))

        assertEquals(
            "SF:package:app/a.dart\nDA:1,1\nDA:2,1\nDA:10,1\nLF:3\nLH:3\nend_of_record\n",
            merged
        )
    }

    @Test
    fun `ignores TN lines and malformed DA entries`() {
        val source = "TN:some test\nSF:package:app/a.dart\nDA:1,1\nDA:bogus\nDA:2\nend_of_record\n"

        val merged = mergeLcov(listOf(source))

        assertEquals(
            "SF:package:app/a.dart\nDA:1,1\nLF:1\nLH:1\nend_of_record\n",
            merged
        )
    }

    @Test
    fun `drops DA lines that appear outside a record`() {
        val source = "DA:1,1\nSF:package:app/a.dart\nDA:2,1\nend_of_record\nDA:3,1\n"

        val merged = mergeLcov(listOf(source))

        assertEquals(
            "SF:package:app/a.dart\nDA:2,1\nLF:1\nLH:1\nend_of_record\n",
            merged
        )
    }

    @Test
    fun `returns empty output for no sources`() {
        assertEquals("", mergeLcov(emptyList()))
    }
}
