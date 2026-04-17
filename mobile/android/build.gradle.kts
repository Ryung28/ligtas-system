buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.browser:browser:1.8.0")
            // 🛡️ TACTICAL BYPASS: Fix for AGP 8.9 requirement loop
            force("androidx.activity:activity:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
            force("androidx.navigationevent:navigationevent-android:1.0.1")
        }
    }
}

subprojects {
    // Only apply namespace fixes to plugins/libraries, not the main app
    if (project.name != "app") {
        val fixNamespace = {
            if (project.hasProperty("android")) {
                val android = project.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
                android?.apply {
                    if (namespace == null) {
                        namespace = "dev.isar.${project.name.replace("-", "_")}"
                    }
                    // 🛡️ RECURSIVE SDK ALIGNMENT: Forces every dependent plugin to 35
                    compileSdkVersion(35)
                }
            }
        }

        if (project.state.executed) {
            fixNamespace()
        } else {
            project.afterEvaluate { fixNamespace() }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
