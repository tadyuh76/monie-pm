plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.monie"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable Java 8 desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.monie"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import Firebase BoM (giúp quản lý version các thư viện Firebase tự động)
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Thêm thư viện Analytics (tùy chọn, để test kết nối)
    implementation("com.google.firebase:firebase-analytics")
    
    // Java 8 desugaring for flutter_local_notifications compatibility
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Nếu sau này dùng Authentication hay Firestore thì thêm vào đây, ví dụ:
    // implementation("com.google.firebase:firebase-auth")
}