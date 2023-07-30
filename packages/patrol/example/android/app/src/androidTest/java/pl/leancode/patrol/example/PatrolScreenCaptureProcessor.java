package pl.leancode.patrol.example;

import android.content.Context;
import android.util.Log;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.screenshot.BasicScreenCaptureProcessor;
import androidx.test.runner.screenshot.ScreenCapture;
import androidx.test.runner.screenshot.ScreenCaptureProcessor;

import java.io.IOException;
import java.nio.file.FileSystems;

public class PatrolScreenCaptureProcessor implements ScreenCaptureProcessor {

    @Override
    public String process(ScreenCapture capture) {
        ScreenshotUtils.storeFailureScreenshot(capture.getBitmap(), capture.getName());

        return null;
    }
}
