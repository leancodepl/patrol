package pl.leancode.patrol

/**
 * Constants used by the Automator class
 */
object AutomatorConstants {
    /**
     * Timeout for waiting for permission dialog to appear (in milliseconds)
     */
    const val PERMISSION_DIALOG_WAIT_TIMEOUT = 2000L

    /**
     * Resource ID for Google Camera shutter button
     * Used as fallback when the default done button is not visible
     */
    const val GOOGLE_CAMERA_SHUTTER_BUTTON_RES_ID = "com.google.android.GoogleCamera:id/shutter_button"
}
