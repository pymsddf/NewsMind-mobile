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

subprojects {
    // Dynamically align Kotlin compile targets with their respective Java compile task targets
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        val javaCompileName = name.replace("Kotlin", "JavaWithJavac")
        val javaCompileTask = project.tasks.withType<JavaCompile>().findByName(javaCompileName)
        if (javaCompileTask != null) {
            val targetCompat = javaCompileTask.targetCompatibility
            if (targetCompat != null && targetCompat.isNotEmpty()) {
                compilerOptions {
                    val jvmTargetValue = when (targetCompat) {
                        "1.8" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
                        "1.8.0" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
                        "8" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
                        "11" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
                        "17" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                        else -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                    }
                    jvmTarget.set(jvmTargetValue)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
