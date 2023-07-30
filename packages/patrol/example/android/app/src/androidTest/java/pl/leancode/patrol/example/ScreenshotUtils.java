package pl.leancode.patrol.example;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import androidx.test.platform.app.InstrumentationRegistry;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class ScreenshotUtils {

    private static final String SCREENSHOT_FOLDER_LOCATION = "/Failure_Screenshots/";

    public static void storeFailureScreenshot(Bitmap bitmap, String screenshotName) {
        ContentResolver contentResolver = InstrumentationRegistry.getInstrumentation().getTargetContext().getApplicationContext().getContentResolver();
        ContentValues contentValues = new ContentValues();
        contentValues.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
        contentValues.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());

        if (Build.VERSION.SDK_INT >= 29) {
            useMediaStoreScreenshotStorage(contentValues, contentResolver, screenshotName, SCREENSHOT_FOLDER_LOCATION, bitmap);
        } else {
            usePublicExternalScreenshotStorage(contentValues, contentResolver, screenshotName, SCREENSHOT_FOLDER_LOCATION, bitmap);
        }
    }

    private static void useMediaStoreScreenshotStorage(ContentValues contentValues, ContentResolver contentResolver, String screenshotName, String screenshotLocation, Bitmap bitmap) {
        contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, screenshotName + ".jpeg");
        contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, Environment.Direc + screenshotLocation);


        Uri uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
        Log.d("ScreenshotTakingRule", "taking screenshot..." + uri);
        String realPath = getRealPathFromURI(InstrumentationRegistry.getInstrumentation().getTargetContext(), uri);
        Log.d("ScreenshotTakingRule", "taking screenshot..." + realPath);

        if (uri != null) {
            try {
                OutputStream outputStream = contentResolver.openOutputStream(uri);
                if (outputStream != null) {
                    saveScreenshotToStream(bitmap, outputStream);
                }
            } catch (IOException e) {
                Log.d("ScreenshotTakingRule", "taking screenshot..." + e);
            }
            contentResolver.update(uri, contentValues, null, null);
        }
    }

    private static void usePublicExternalScreenshotStorage(ContentValues contentValues, ContentResolver contentResolver, String screenshotName, String screenshotLocation, Bitmap bitmap) {
        File directory = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES + screenshotLocation).toString());
        if (!directory.exists()) {
            directory.mkdirs();
        }

        File file = new File(directory, screenshotName + ".jpeg");
        try {
            saveScreenshotToStream(bitmap, new FileOutputStream(file));
        } catch (IOException e) {
            Log.d("ScreenshotTakingRule", "taking screenshot..." + e);
        }

        contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
    }

    private static void saveScreenshotToStream(Bitmap bitmap, OutputStream outputStream) {
        try {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 50, outputStream);
        } finally {
            try {
                outputStream.close();
            } catch (IOException e) {
                Log.d("ScreenshotTakingRule", "taking screenshot..." + e);
            }
        }
    }

    public static String getRealPathFromURI(Context context, Uri contentUri) {
        Cursor cursor = null;
        try {
            String[] projection = { MediaStore.Images.Media.DATA };
            cursor = context.getContentResolver().query(contentUri, projection, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return null;
    }
}
