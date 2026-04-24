plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.elman.carehelper"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Исправлено: всё это должно быть ВНУТРИ блока android
    sourceSets {
        getByName("main") {
            resources.srcDirs("src/main/resources")
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.elman.carehelper"
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // ВНИМАНИЕ: Для финальной версии в Google Play здесь нужно будет 
            // сменить на твой релизный конфиг подписи!
            signingConfig = signingConfigs.getByName("debug")
        }
    }
} // Вот тут закрывается блок android

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}


