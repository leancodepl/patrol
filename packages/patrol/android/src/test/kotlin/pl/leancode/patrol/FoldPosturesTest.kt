package pl.leancode.patrol

import org.junit.Test
import pl.leancode.patrol.contracts.Contracts.AndroidFoldPosture
import kotlin.test.assertEquals

class FoldPosturesTest {
    @Test
    fun `parseFoldDeviceStates() reads the postures of a foldable`() {
        // given, from the Pixel 9 Pro Fold emulator
        val output = """
            Supported states: [
              DeviceState{identifier=0, name='CLOSED', app_accessible=true, cancel_when_requester_not_on_top=false},
              DeviceState{identifier=1, name='HALF_OPENED', app_accessible=true, cancel_when_requester_not_on_top=false},
              DeviceState{identifier=2, name='OPENED', app_accessible=true, cancel_when_requester_not_on_top=false},
              DeviceState{identifier=3, name='REAR_DISPLAY_MODE', app_accessible=true, cancel_when_requester_not_on_top=false},
            ]
        """.trimIndent()

        // when
        val states = parseFoldDeviceStates(output)

        // then
        assertEquals(
            mapOf(
                AndroidFoldPosture.closed to 0,
                AndroidFoldPosture.halfOpen to 1,
                AndroidFoldPosture.open to 2
            ),
            states
        )
    }

    @Test
    fun `parseFoldDeviceStates() reads states without extra fields`() {
        val output = "Supported states: [ DeviceState{identifier=4, name='CLOSED'}, DeviceState{identifier=7, name='OPENED'} ]"

        val states = parseFoldDeviceStates(output)

        assertEquals(mapOf(AndroidFoldPosture.closed to 4, AndroidFoldPosture.open to 7), states)
    }

    @Test
    fun `parseFoldDeviceStates() returns nothing for a device that doesn't fold`() {
        val output = """
            Supported states: [
              DeviceState{identifier=0, name='DEFAULT', app_accessible=true, cancel_when_requester_not_on_top=false},
            ]
        """.trimIndent()

        assertEquals(emptyMap(), parseFoldDeviceStates(output))
    }

    @Test
    fun `parseFoldDeviceStates() returns nothing without the device_state service`() {
        assertEquals(emptyMap(), parseFoldDeviceStates("cmd: Can't find service: device_state"))
    }
}
