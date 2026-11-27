plugins {
    id("com.android.test")
}

apply(from = project(":patrol_android_test").projectDir.resolve("patrol_test.gradle"))
