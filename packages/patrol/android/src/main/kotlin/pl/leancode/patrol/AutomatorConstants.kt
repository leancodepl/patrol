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
     * Resource ID for emulator camera shutter button
     * Used on Android emulator devices
     */
    const val EMULATOR_CAMERA_SHUTTER_BUTTON_RES_ID = "com.android.camera2:id/shutter_button"

    /**
     * Resource ID for Google Camera shutter button
     * Used on physical devices with Google Camera app
     */
    const val GOOGLE_CAMERA_SHUTTER_BUTTON_RES_ID = "com.google.android.GoogleCamera:id/shutter_button"

    /**
     * Resource ID for emulator camera done button
     * Used on Android emulator devices to confirm photo capture
     */
    const val EMULATOR_CAMERA_DONE_BUTTON_RES_ID = "com.android.camera2:id/done_button"

    /**
     * Resource ID for Google Camera done button
     * Used on physical devices with Google Camera app to confirm photo capture
     */
    const val GOOGLE_CAMERA_DONE_BUTTON_RES_ID = "com.google.android.GoogleCamera:id/done_button"

    /**
     * Resource ID for gallery image thumbnail on Android API 34-35
     * Used to identify and select images in the gallery
     */
    const val GALLERY_IMAGE_THUMBNAIL_RES_ID = "com.google.android.providers.media.module:id/icon_thumbnail"

    /**
     * Resource ID for gallery image thumbnail on Android API < 34
     * Used to identify and select images in the gallery
     */
    const val GALLERY_IMAGE_THUMB_RES_ID = "com.google.android.documentsui:id/icon_thumb"

    /**
     * Content description pattern for photo items in gallery on Android API 36+
     * Used to identify images by their content description when resource IDs are not available
     */
    const val PHOTO_TAKEN_ON_CONTENT_DESCRIPTION = "Photo taken on"

    /**
     * Resource ID for the submenu list in gallery on Android API < 34
     * Used for navigation in the older gallery interface
     */
    const val GALLERY_SUB_MENU_LIST_RES_ID = "com.google.android.documentsui:id/sub_menu_list"

    /**
     * Button text for the "Done" action button in gallery on Android API 36+
     * Used to confirm selection when picking images from gallery
     */
    const val GALLERY_DONE_BUTTON_TEXT = "Done"

    /**
     * Resource ID for the "Add" button in gallery on Android API 34-35
     * Used to confirm selection when picking images from gallery
     */
    const val GALLERY_ADD_BUTTON_RES_ID = "com.google.android.providers.media.module:id/button_add"

    /**
     * Resource ID for the "Select" action menu button in gallery on Android API < 34
     * Used to confirm selection when picking images from gallery
     */
    const val GALLERY_SELECT_BUTTON_RES_ID = "com.google.android.documentsui:id/action_menu_select"
}
