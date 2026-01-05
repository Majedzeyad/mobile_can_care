# حل مشاكل تحميل البيانات التجريبية

## المشكلة: زر "تحميل بيانات تجريبية" لا يعمل

### الحلول الممكنة:

#### 1. تأكد من تسجيل الدخول أولاً
- الزر يتطلب تسجيل الدخول أولاً
- بعد تسجيل الدخول، اضغط على الزر
- إذا لم تكن مسجل دخول، ستظهر رسالة: "الرجاء تسجيل الدخول أولاً"

#### 2. تحقق من Console Logs
افتح Console/Logcat وابحث عن:
```
[LoginPage] Load sample data button pressed
[LoginPage] Checking if user is logged in...
[SampleDataLoader] Starting to load sample data...
```

#### 3. تحقق من Firebase Connection
- تأكد من أن Firebase متصل
- تحقق من `google-services.json` موجود في `android/app/`
- تأكد من إضافة SHA-1 fingerprint في Firebase Console

#### 4. تحقق من الأخطاء
إذا ظهرت أخطاء في Console:
- اقرأ رسالة الخطأ بالكامل
- تحقق من أن جميع Collections موجودة في Firebase
- تأكد من أن المستخدم لديه صلاحيات الكتابة في Firestore

#### 5. اختبار يدوي
1. سجّل الدخول
2. افتح Console/Logcat
3. اضغط على زر "تحميل بيانات تجريبية"
4. راقب الرسائل في Console
5. إذا ظهر خطأ، انسخه وأرسله

#### 6. إعادة المحاولة
إذا فشل التحميل:
- أعد تسجيل الدخول
- اضغط على الزر مرة أخرى
- قد تكون بعض البيانات موجودة بالفعل (هذا طبيعي)

## البيانات التي يتم إنشاؤها:

1. ✅ ملف الطبيب (Doctor Profile)
2. ✅ 2 ممرضات (Nurses)
3. ✅ 4 مرضى (Patients)
4. ✅ 8 أدوية (Medications)
5. ✅ 3 طلبات تحاليل (Lab Test Requests)
6. ✅ 3 نتائج تحاليل (Lab Results)
7. ✅ 3 وصفات طبية (Prescriptions)
8. ✅ 3 سجلات طبية (Medical Records)
9. ✅ 2 طلبات تجاوز (Override Requests)
10. ✅ 3 مواعيد (Appointments)

## ملاحظات:

- البيانات لا تُنشأ إذا كانت موجودة مسبقاً (لتجنب التكرار)
- جميع البيانات مرتبطة بالطبيب الحالي (currentUserId)
- يمكن تشغيل التحميل عدة مرات بأمان

## إذا استمرت المشكلة:

1. تحقق من Firebase Console → Firestore Database
2. تأكد من أن Rules تسمح بالكتابة:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
3. تحقق من أن المستخدم مسجل دخول في Firebase Auth
4. أعد بناء التطبيق:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```


