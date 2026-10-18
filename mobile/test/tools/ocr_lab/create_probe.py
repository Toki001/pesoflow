"""Materialize an isolated Android probe outside the repo; never installs it."""
import argparse
import pathlib
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("output", type=pathlib.Path)
parser.add_argument("inputs", type=pathlib.Path)
parser.add_argument("sdk", type=pathlib.Path)
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[4]
output = args.output.resolve()
if output == root or root in output.parents:
    parser.error("Use a temporary output directory outside the repository.")
output.mkdir(parents=True, exist_ok=False)
(output / "settings.gradle").write_text('''pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = 'PesoFlowOcrProbe'
''')
(output / "build.gradle").write_text('''plugins { id 'com.android.application' version '9.1.0' }
android {
    namespace 'dev.pesoflow.ocrprobe'
    compileSdk 36
    defaultConfig { applicationId 'dev.pesoflow.ocrprobe'; minSdk 26; targetSdk 36; versionCode 1; versionName 'diagnostic' }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
}
dependencies { implementation 'com.google.mlkit:text-recognition:16.0.1' }
''')
(output / "gradle.properties").write_text("android.useAndroidX=true\norg.gradle.jvmargs=-Xmx2G\n")
(output / "local.properties").write_text(f"sdk.dir={args.sdk.resolve()}\n")
source = output / "src/main"
source.mkdir(parents=True)
(source / "AndroidManifest.xml").write_text('''<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools">
<uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove"/>
<application android:label="PesoFlow OCR Lab" android:allowBackup="false" android:theme="@android:style/Theme.Material.Light.NoActionBar">
<activity android:name=".OcrProbeActivity" android:exported="true"><intent-filter><action android:name="android.intent.action.MAIN"/><category android:name="android.intent.category.LAUNCHER"/></intent-filter></activity>
</application></manifest>
''')
java = source / "java/dev/pesoflow/ocrprobe"
java.mkdir(parents=True)
shutil.copyfile(pathlib.Path(__file__).with_name("OcrProbeActivity.java"), java / "OcrProbeActivity.java")
shutil.copytree(args.inputs, source / "assets")
print("Created isolated probe project; private inputs stay outside the repository.")
