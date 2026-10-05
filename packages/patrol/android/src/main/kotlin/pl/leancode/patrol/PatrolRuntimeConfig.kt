package pl.leancode.patrol

internal fun patrolBuildConfigString(fieldName: String): String? {
    return runCatching {
        Class.forName("pl.leancode.patrol.BuildConfig")
            .getField(fieldName)
            .get(null) as? String
    }.getOrNull()
}
