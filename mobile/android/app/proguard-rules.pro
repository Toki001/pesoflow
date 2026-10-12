# PesoFlow exclusively requests ML Kit's bundled Latin recognizer (script 0).
# The Flutter adapter contains branches for optional, unbundled script modules.
# Suppress only those absent options; keep R8 enabled and other missing classes
# visible. Add their native dependencies before enabling another script.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder

# ML Kit discovers these bundled registrars by manifest class name and calls
# their no-argument constructors reflectively. R8 full mode otherwise removes
# those constructors, causing release-only ComponentDiscovery/OCR failures.
# Retain only these entry points, rather than disabling shrinking for ML Kit.
-keep class com.google.mlkit.common.internal.CommonComponentRegistrar {
    public <init>();
    public java.util.List getComponents();
}
-keep class com.google.mlkit.vision.common.internal.VisionCommonRegistrar {
    public <init>();
    public java.util.List getComponents();
}
-keep class com.google.mlkit.vision.text.internal.TextRegistrar {
    public <init>();
    public java.util.List getComponents();
}
