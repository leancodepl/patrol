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

    /**
     * Content description pattern for photo items in gallery on Android API 36+
     * Used to identify images by their content description when resource IDs are not available
     */
    const val PHOTO_TAKEN_ON_CONTENT_DESCRIPTION = "Photo taken on"

    /**
     * Button text for the "Done" action button in gallery on Android API 36+
     * Used to confirm selection when picking images from gallery
     */
    const val GALLERY_DONE_BUTTON_TEXT = "Done"
}
