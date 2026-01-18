# iOS Build Instructions - تعليمات بناء iOS

## المتطلبات
1. **macOS** - يجب استخدام جهاز Mac لبناء تطبيقات iOS
2. **Xcode** - الإصدار 15.0 أو أحدث
3. **CocoaPods** - لإدارة المكتبات

## خطوات الإعداد

### 1. تثبيت CocoaPods (إن لم يكن مثبتاً)
```bash
sudo gem install cocoapods
```

### 2. الانتقال لمجلد iOS وتثبيت المكتبات
```bash
cd ios
pod install
```

### 3. إضافة مفتاح Google Maps API
افتح ملف `ios/Runner/AppDelegate.swift` واستبدل:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```
بمفتاح API الخاص بك من [Google Cloud Console](https://console.cloud.google.com/)

### 4. فتح المشروع في Xcode
```bash
open Runner.xcworkspace
```
**ملاحظة:** استخدم `.xcworkspace` وليس `.xcodeproj`

### 5. تحديد فريق التطوير
1. في Xcode، اضغط على "Runner" في القائمة اليسرى
2. اختر تبويب "Signing & Capabilities"
3. اختر "Team" الخاص بك

### 6. تشغيل التطبيق
```bash
flutter run -d ios
```

## الصلاحيات المضافة
تم إضافة الصلاحيات التالية في `Info.plist`:
- ✅ الكاميرا (`NSCameraUsageDescription`)
- ✅ مكتبة الصور (`NSPhotoLibraryUsageDescription`)
- ✅ حفظ الصور (`NSPhotoLibraryAddUsageDescription`)
- ✅ الميكروفون (`NSMicrophoneUsageDescription`)
- ✅ الموقع (`NSLocationWhenInUseUsageDescription`)

## حل المشاكل الشائعة

### مشكلة CocoaPods
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
```

### مشكلة في المكتبات
```bash
flutter clean
flutter pub get
cd ios
pod install
```

### مشكلة في Xcode
```bash
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
cd ios
pod install
```

## بناء النسخة للنشر
```bash
flutter build ios --release
```

ثم استخدم Xcode لرفع التطبيق على App Store Connect.
