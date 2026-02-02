
extra["android.buildToolsVersion"] = "33.0.2"

// 2. 配置所有项目的依赖仓库（Kotlin DSL 标准写法，与原功能一致）
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. 重定向构建产物目录（Kotlin DSL 语法，替换 Groovy 的 .value() 为 .set()）
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

// 为所有子项目配置对应的构建子目录
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// 4. 配置子项目依赖 :app 模块的评估结果（Kotlin DSL 简化写法，功能一致）
subprojects {
    evaluationDependsOn(":app")
}

// 5. 注册 clean 任务，删除根项目构建目录（纯 Kotlin DSL 语法）
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
