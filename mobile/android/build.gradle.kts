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
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.browser" && requested.name == "browser") {
                useVersion("1.8.0")
                because("Higher versions require AGP 8.9.1+")
            }
            if (requested.group == "androidx.core" && (requested.name == "core" || requested.name == "core-ktx")) {
                if (requested.version?.startsWith("1.15") == false && requested.version?.startsWith("1.14") == false && requested.version?.startsWith("1.13") == false) {
                    useVersion("1.13.1")
                    because("Higher versions require AGP 8.9.1+")
                }
            }
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
