# Consumer ProGuard rules for MobileTracker SDK

# Keep public API classes and methods
-keep public class ai.founderos.mobiletracker.MobileTracker {
    public *;
}

-keep public class ai.founderos.mobiletracker.TrackerConfig {
    public *;
}

# Keep data model classes for serialization
-keep class ai.founderos.mobiletracker.** { *; }

# Keep Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep serializers
-keep,includedescriptorclasses class ai.founderos.mobiletracker.**$$serializer { *; }
-keepclassmembers class ai.founderos.mobiletracker.** {
    *** Companion;
}
-keepclasseswithmembers class ai.founderos.mobiletracker.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
