# Keep Flutter engine + Dio; default rules handle the rest
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
