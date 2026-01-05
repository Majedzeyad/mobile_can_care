# دليل إعداد أيقونة التطبيق - CanCare Logo

## الخطوات المطلوبة:

### 1. إضافة الصورة إلى Assets
- ضع صورة `cancare_logo.png` في مجلد `assets/images/`
- الحجم الموصى به: **1024x1024 بكسل** (PNG مع خلفية شفافة)

### 2. تحديث أيقونة Android

#### الطريقة الأولى: استخدام Flutter Launcher Icons (موصى به)
1. أضف الحزمة إلى `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. أضف الإعدادات في `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/cancare_logo.png"
  adaptive_icon_background: "#000000"  # خلفية سوداء
  adaptive_icon_foreground: "assets/images/cancare_logo.png"
```

3. شغّل الأمر:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

#### الطريقة الثانية: يدوياً
استبدل ملفات `ic_launcher.png` في:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### 3. تحديث أيقونة iOS

1. افتح `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. استبدل جميع ملفات `Icon-App-*.png` بالشعار
3. أو استخدم Flutter Launcher Icons (الطريقة الأولى)

### 4. تحديث أيقونة Web

استبدل الملفات في `web/icons/`:
- `Icon-192.png` (192x192)
- `Icon-512.png` (512x512)
- `favicon.png` (32x32 أو 16x16)

## ملاحظات:
- ✅ تم تحديث الكود لاستخدام الصورة في:
  - صفحة تسجيل الدخول
  - Drawer في صفحات الطبيب
- ⚠️ إذا لم تكن الصورة موجودة، سيتم استخدام الأيقونة الافتراضية كبديل
- 📱 بعد إضافة الصورة، قم بتشغيل `flutter clean` ثم `flutter pub get`


