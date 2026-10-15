allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// camera_android_camerax currently omits this CameraX compile dependency.
// Add it to the plugin module itself (not only to :app).
subprojects {
    pluginManager.withPlugin("com.android.library") {
        if (name == "camera_android_camerax") {
            dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}

// Flutter registers plugin projects after this root build script starts.
// Registering before each project guarantees the dependency is attached to
// camera_android_camerax before its Android library plugin is configured.
gradle.beforeProject {
    if (path == ":camera_android_camerax") {
        pluginManager.withPlugin("com.android.library") {
            dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
