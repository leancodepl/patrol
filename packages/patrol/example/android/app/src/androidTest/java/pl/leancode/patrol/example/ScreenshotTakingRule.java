package pl.leancode.patrol.example;

import static android.os.Environment.DIRECTORY_PICTURES;

import android.app.UiAutomation;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import androidx.test.InstrumentationRegistry;
import androidx.test.core.app.DeviceCapture;
import androidx.test.runner.screenshot.BasicScreenCaptureProcessor;
import androidx.test.runner.screenshot.ScreenCapture;
import androidx.test.runner.screenshot.ScreenCaptureProcessor;
import androidx.test.runner.screenshot.Screenshot;

import org.junit.rules.TestWatcher;
import org.junit.runner.Description;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

public class ScreenshotTakingRule extends TestWatcher {
    private static final String WRITE_PERMISSION = "android.permission.WRITE_EXTERNAL_STORAGE";
    private static final String READ_PERMISSION = "android.permission.READ_EXTERNAL_STORAGE";
    private static final String[] REQUIRED_PERMISSIONS =
            new String[] {WRITE_PERMISSION, READ_PERMISSION};

    private void checkPermissions() {
        for (String permission : REQUIRED_PERMISSIONS) {
            if (Build.VERSION.SDK_INT < 23) {
                throw new RuntimeException("We need " + permission + " permission for screenshot tests");
            }
            Context targetContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
            grantPermission(targetContext, permission);
        }
    }

    private void grantPermission(Context context, String permission) {
        if (Build.VERSION.SDK_INT < 23) {
            return;
        }
        UiAutomation automation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
        String command =
                String.format(Locale.ENGLISH, "pm grant %s %s", context.getPackageName(), permission);
        ParcelFileDescriptor pfd = automation.executeShellCommand(command);
        InputStream stream = new FileInputStream(pfd.getFileDescriptor());
        try {
            byte[] buffer = new byte[1024];
            while (stream.read(buffer) != -1) {
                // Consume stdout to ensure the command completes
            }
        } catch (IOException ignored) {
        } finally {
            try {
                stream.close();
            } catch (IOException ignored) {
            }
            try {
                pfd.close();
            } catch (IOException ignored) {
            }
        }
    }

    @Override
    protected void failed(Throwable e, Description description) {
        Log.d("ScreenshotTakingRule", "taking screenshot..." + description.getMethodName());
        takeScreenshot(description.getMethodName());
    }

    @Override
    protected void succeeded(Description description) {
        Log.d("ScreenshotTakingRule", "taking screenshot..." + description.getMethodName());
        takeScreenshot(description.getMethodName());
    }

    private void takeScreenshot(String screenShotName) {
//            checkPermissions();
//            File picturesDir = android.os.Environment.getExternalStoragePublicDirectory(DIRECTORY_PICTURES);
//            picturesDir.setWritable(true, false);
//            Log.d("ScreenshotTakingRule", picturesDir.getAbsolutePath());
//            File screenshotsDir = new File(picturesDir, "screenshots");
//            screenshotsDir.mkdir();
//            screenshotsDir.setWritable(true, false);
//            Log.d("ScreenshotTakingRule", screenshotsDir.getAbsolutePath());
            ScreenCapture screenCapture = Screenshot.capture();
            screenCapture.setName(screenShotName);
            PatrolScreenCaptureProcessor processor = new PatrolScreenCaptureProcessor();
            processor.process(screenCapture);
    }
}