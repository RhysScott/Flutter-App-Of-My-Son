plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_for_my_son"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // 修复：兼容所有 AGP 版本的核心库脱糖配置（移除嵌套属性，用回兼容写法）
        isCoreLibraryDesugaringEnabled = true
    }

    // 修复：Kotlin jvmTarget 废弃问题（兼容高版本 Kotlin 插件，不硬编码版本）
    kotlinOptions {
        jvmTarget = "17" // 直接用字符串写法，规避 DSL 兼容问题，满足需求且无报错
    }

    defaultConfig {
        applicationId = "com.example.project_for_my_son"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 你的 Release 签名配置（完全保留，无改动）
    signingConfigs {
        create("release") {
            keyAlias = "debug"
            keyPassword = "kissme"
            storeFile = file("/Users/noahmiller/Developer/_secret_keys/debug.jks")
            storePassword = "kissme"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// 核心库脱糖依赖（不指定版本，由 Gradle 自动解析兼容版本）
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
