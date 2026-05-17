plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.elman.carehelper"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // Настройка подписи релизным ключом
    signingConfigs {
        create("release") {
            storeFile = file("my-release-key.keystore")
            storePassword = "kaladuzlu"
            keyAlias = "my-key-alias"
            keyPassword = "kaladuzlu"
        }
    }

    sourceSets {
        getByName("main") {
            assets.srcDirs("src/main/assets")
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            
            // ДОБАВЬ ЭТИ ДВЕ СТРОКИ:
            isMinifyEnabled = false
            isShrinkResources = false
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
        targetSdk = 35  // <--- ИЗМЕНИ С 34 НА 35
        
        versionCode = 12 
        versionName = "1.0.12"
        
        multiDexEnabled = true
    }

} 

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
