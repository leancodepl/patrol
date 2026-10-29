package pl.leancode.patrol

import pl.leancode.patrol.contracts.Contracts.AndroidFoldPosture

// Device state names on AOSP foldables, such as the Pixel Fold.
private val deviceStateNames = mapOf(
    AndroidFoldPosture.closed to "CLOSED",
    AndroidFoldPosture.halfOpen to "HALF_OPENED",
    AndroidFoldPosture.open to "OPENED"
)

private val deviceStateRegex = Regex("""DeviceState\{identifier=(\d+), name='([^']*)'""")

/** Device state ids by posture, from `cmd device_state print-states`. */
fun parseFoldDeviceStates(printStatesOutput: String): Map<AndroidFoldPosture, Int> {
    val idsByName = deviceStateRegex.findAll(printStatesOutput)
        .associate { it.groupValues[2] to it.groupValues[1].toInt() }

    return deviceStateNames.entries
        .mapNotNull { (posture, name) -> idsByName[name]?.let { posture to it } }
        .toMap()
}
