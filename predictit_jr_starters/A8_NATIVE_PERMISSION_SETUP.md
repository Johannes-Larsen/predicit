# A8 Native Permission Setup

This project includes the Android and iOS permission declarations needed for A8.

Android file:

`android/app/src/main/AndroidManifest.xml`

Required permissions are above the `<application>` tag:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

iOS file:

`ios/Runner/Info.plist`

Required keys:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSLocationWhenInUseUsageDescription`

After changing native permissions or adding plugins, use a full rebuild, not hot reload:

```bash
flutter clean
flutter pub get
flutter run
```
