<<<<<<< HEAD
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
=======
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
>>>>>>> 90e314c0eba4e980296523a123ab56091c512c34
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

<<<<<<< HEAD
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
=======
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
apply(plugin = "com.google.gms.google-services")
>>>>>>> 90e314c0eba4e980296523a123ab56091c512c34
