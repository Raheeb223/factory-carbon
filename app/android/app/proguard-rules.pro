# google_mlkit_text_recognition references the optional Chinese, Devanagari, Japanese
# and Korean recognizers. Only the Latin one is bundled, so let R8 skip the others.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit creates parts of the text recognizer by reflection; without these R8 strips them
# and processImage fails at runtime with a NullPointerException (release builds only).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_bundled_common.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
