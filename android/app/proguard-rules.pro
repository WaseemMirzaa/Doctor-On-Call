# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase specific rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# GetX specific rules
-keep class com.example.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Samsung specific rules
-keep class com.samsung.** { *; }
-dontwarn com.samsung.**

# General Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Prevent obfuscation of model classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# RevenueCat specific rules
-keep class com.revenuecat.purchases.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.revenuecat.purchases.**
-dontwarn com.android.billingclient.**

# Keep billing library classes
-keep class com.android.vending.billing.**
-keepclassmembers class com.android.vending.billing.** {
    *;
}
