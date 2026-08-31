plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    //id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.awadh.farm_expense_mangement_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    }

    defaultConfig {
        applicationId = "com.awadh.farm_expense_management_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        //myAppName = "DairySangrah-v${versionName}-(${versionCode})"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

afterEvaluate {

    val versionCode = flutter.versionCode
    val versionName = flutter.versionName
    val myAppName = "DairySangrah-v${versionName}-(${versionCode})"

    tasks.matching {
        it.name == "assembleDebug"
    }.configureEach {
        doLast {
            val source = file("$buildDir/outputs/flutter-apk/app-debug.apk")
            val target = file("$buildDir/outputs/flutter-apk/$myAppName-debug.apk")

            if (source.exists()) {
                source.copyTo(target, overwrite = true)
                println("Created: ${target.name}")
            }
        }
    }

    tasks.matching {
        it.name == "assembleRelease"
    }.configureEach {
        doLast {
            val source = file("$buildDir/outputs/flutter-apk/app-release.apk")
            val target = file("$buildDir/outputs/flutter-apk/$myAppName-release.apk")

            if (source.exists()) {
                source.copyTo(target, overwrite = true)
                println("Created: ${target.name}")
            }
        }
    }

    tasks.matching {
        it.name == "bundleRelease"
    }.configureEach {
        doLast {
            val source = file("$buildDir/outputs/bundle/release/app-release.aab")
            val target = file("$buildDir/outputs/bundle/release/$myAppName-release.aab")

            if (source.exists()) {
                source.copyTo(target, overwrite = true)
                println("Created: ${target.name}")
            }
        }
    }
}
