import com.android.build.api.dsl.ApplicationExtension

plugins {
    id("com.android.test")
}

val appAndroid = project(":app").extensions.getByType(ApplicationExtension::class.java)
val appNamespace = requireNotNull(appAndroid.namespace) {
    "The :app module must declare an Android namespace"
}

android {
    namespace = "$appNamespace.patrol_test"
    compileSdk = appAndroid.compileSdk

    defaultConfig {
        minSdk = appAndroid.defaultConfig.minSdk
        targetSdk = appAndroid.defaultConfig.targetSdk
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        // Clear the app under test before each test.
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    flavorDimensions += appAndroid.flavorDimensions
    appAndroid.productFlavors.forEach { appFlavor ->
        productFlavors.create(appFlavor.name) {
            dimension = appFlavor.dimension
        }
    }
    appAndroid.buildTypes.forEach { appBuildType ->
        if (buildTypes.findByName(appBuildType.name) == null) {
            buildTypes.create(appBuildType.name)
        }
    }
    buildTypes.configureEach {
        if (name != "debug" && name != "release") {
            matchingFallbacks += listOf("release", "debug")
        }
    }

    targetProjectPath = ":app"
    experimentalProperties["android.experimental.self-instrumenting"] = true

    // Give every Dart test a fresh instrumentation process.
    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }
}

dependencies {
    implementation(project(":patrol_test_harness"))
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}

apply(from = project(":patrol_test_harness").projectDir.resolve("patrol_test.gradle"))
