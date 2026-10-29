# The test APK calls these classes from the app APK, and R8 in the app cannot see those calls.
-keep class pl.leancode.patrol.** { *; }
-keep class org.junit.runners.** { *; }
# The runner of the test classes that `patrol build android --emit-test-manifest` generates.
-keep class androidx.test.runner.AndroidJUnit4 { *; }

# Referenced by ktor's JVM debugger check, which never runs on Android.
-dontwarn java.lang.management.ManagementFactory
-dontwarn java.lang.management.RuntimeMXBean
