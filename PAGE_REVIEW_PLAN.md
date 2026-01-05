# 📋 خطة مراجعة شاملة لجميع صفحات CanCare

---

## 📊 ملخص الصفحات

| الدور | عدد الصفحات | الحالة |
|------|-------------|--------|
| **المرضى (Patient)** | 9 صفحات | ⏳ جاري |
| **الأطباء (Doctor)** | 9 صفحات | ⏳ جاري |
| **الممرضين (Nurse)** | 18 صفحة | ⏳ جاري |
| **المجموع** | **36 صفحة** | - |

---

## 🎯 المبادئ المُطبَّقة على جميع الصفحات

استخدم [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) كمرجع أساسي لجميع التحديثات.

### التغييرات الأساسية لكل صفحة:
1. ✅ استخدام `theme.colorScheme.primary/secondary` بدلاً من ألوان hardcoded
2. ✅ استخدام `theme.textTheme.___` لجميع النصوص
3. ✅ استبدال Firebase بـTODO markers
4. ✅ زيادة أحجام الأزرار (64px للمرضى)
5. ✅ زيادة المسافات (20px padding للمرضى)
6. ✅ تحسين الرسائل لتكون مطمئنة

---

## 👤 صفحات المرضى (Patient Pages)

### ✅ 1. Patient Dashboard
**الحالة**: مكتمل ✓  
**المسار**: `lib/Patient/patient_dashboard.dart`

**التحديثات المُنفذة**:
- ✅ إعادة تصميم كاملة
- ✅ ألوان هادئة من Theme
- ✅ خطوط كبيرة (19-36px)
- ✅ أزرار 64px
- ✅ زر SOS بارز
- ✅ TODO markers للـBackend

---

### ⏳ 2. Patient Appointment Management
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Patient/patient_appointment_management.dart`

**التحديثات المطلوبة**:
- [ ] استبدال `Color(0xFF6B46C1)` بـ`theme.colorScheme.primary`
- [ ] تكبير حجم Calendar
- [ ] تحسين كروت المواعيد:
  - أيقونات كبيرة (32px)
  - حشوة 24px
  - border-radius 20px
  - تدرج لوني ناعم
- [ ] استبدال شريط البحث بتصميم جديد
- [ ] إضافة TODO markers

**التصميم المقترح**:
```dart
// كرت موعد محسّن
Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.primary.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: theme.colorScheme.primary.withOpacity(0.2),
      width: 2,
    ),
  ),
  child: Row(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.medical_services,
          size: 32,
          color: theme.colorScheme.primary,
        ),
      ),
      const SizedBox(width: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment['doctor'],
              style: theme.textTheme.titleLarge,
            ),
            Text(
              '${appointment['date']} - ${appointment['time']}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

### ⏳ 3. Patient Medication Management
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Patient/patient_medication_management.dart`

**التحديثات المطلوبة**:
- [ ] تحسين Next Dosage Banner:
  - تدرج لوني بدلاً من لون واحد
  - أيقونة أكبر (32px)
  - نص أكبر (18px)
- [ ] كروت أدوية محسّنة:
  - أيقونة دواء كبيرة
  - checkbox أكبر (32px)
  - معلومات الجرعة واضحة
- [ ] استبدال Firebase بـTODO
- [ ] رسائل مطمئنة

**التصميم المقترح**:
```dart
// كرت دواء محسّن
Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: med['taken']
        ? theme.colorScheme.secondary.withOpacity(0.1)
        : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: med['taken']
          ? theme.colorScheme.secondary.withOpacity(0.3)
          : theme.colorScheme.primary.withOpacity(0.2),
      width: 2,
    ),
  ),
  child: Row(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: med['taken']
              ? theme.colorScheme.secondary.withOpacity(0.2)
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          med['taken'] ? Icons.check_circle : Icons.medication,
          color: med['taken']
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
          size: 28,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              med['name'],
              style: theme.textTheme.titleMedium,
            ),
            Text(
              med['dosage'],
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      Checkbox(
        value: med['taken'],
        onChanged: (value) {},
        activeColor: theme.colorScheme.secondary,
      ),
    ],
  ),
)
```

---

### ⏳ 4. Patient Profile
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Patient/patient_profile.dart`

**التحديثات المطلوبة**:
- [ ] صورة الملف الشخصي أكبر (120px)
- [ ] كروت معلومات محسّنة بتدرجات لونية
- [ ] أيقونات أكبر للمعلومات (24px)
- [ ] زر تحميل المستندات أكبر
- [ ] استبدال Firebase Storage بـTODO

---

### ⏳ 5-9. صفحات أخرى
- `patient_medical_record.dart`
- `patient_lab_results_review.dart`
- `patient_transportation.dart`
- `patient_publication.dart`
- `patient_home.dart`

**نفس المبادئ تُطبّق على جميع الصفحات**.

---

## 👨‍⚕️ صفحات الأطباء (Doctor Pages)

### ✅ 1. Doctor Dashboard (home.dart)
**الحالة**: مكتمل ✓  
**المسار**: `lib/Doctor/home.dart`

---

### ⏳ 2. Doctor Detail
**الحالة**: يحتاج تحسينات طفيفة  
**المسار**: `lib/Doctor/doctor_detail.dart`

**التحديثات المطلوبة**:
- [ ] استخدام Theme colors
- [ ] تحسين layout البطاقات
- [ ] استبدال Firebase بـTODO

---

### ⏳ 3. Patient List
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Doctor/patient_list.dart`

**التحديثات المطلوبة**:
- [ ] كروت مرضى أكبر وأوضح
- [ ] أيقونات حالة المريض ملونة
- [ ] بحث محسّن
- [ ] فلترة بالحالة (نشط/غير نشط)

---

### ⏳ 4. Lab Results Review
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Doctor/lab_results_review.dart`

**التحديثات المطلوبة**:
- [ ] كروت نتائج واضحة
- [ ] ألوان دلالية للنتائج (أخضر/برتقالي/أحمر)
- [ ] زر إضافة ملاحظات بارز
- [ ] استبدال Firebase

---

### ⏳ 5. Incoming Requests
**الحالة**: يحتاج تحسينات  
**المسار**: `lib/Doctor/incoming_requests.dart`

**التحديثات المطلوبة**:
- [ ] استخدام Theme colors بدلاً من hardcoded
- [ ] تحسين كروت الطلبات
- [ ] أزرار قبول/رفض أكبر
- [ ] إشعارات واضحة للطلبات الجديدة

---

### ⏳ 6-9. صفحات أخرى
- `medical_records.dart`
- `medications.dart`
- `override_requests.dart`
- `lab_test_request.dart`

---

## 👩‍⚕️ صفحات الممرضين (Nurse Pages)

### ✅ 1. Nurse Dashboard
**الحالة**: مكتمل ✓  
**المسار**: `lib/Nurse/nurse_dashboard.dart`

---

### ⏳ 2. Nurse Patient Management
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Nurse/nurse_patient_management.dart`

**التحديثات المطلوبة**:
- [ ] قائمة مرضى محسّنة
- [ ] بطاقات مريض بمعلومات واضحة
- [ ] فلترة حسب الحالة
- [ ] استبدال Firebase

---

### ⏳ 3. Nurse Medication Management
**الحالة**: يحتاج تحديث  
**المسار**: `lib/Nurse/nurse_medication_management.dart`

**التحديثات المطلوبة**:
- [ ] جدول أدوية واضح
- [ ] checkbox كبيرة لتأكيد الإعطاء
- [ ] تنبيهات للأدوية المتأخرة
- [ ] استبدال Firebase

---

### ⏳ 4-18. صفحات أخرى
- `nurse_appointment_management.dart`
- `nurse_profile.dart`
- `nurse_publication.dart`
- `nurse_patient_detail.dart`
- `nurse_medical_record.dart`
- وغيرها...

---

## 🔄 عملية التحديث الموحدة

### لكل صفحة، اتبع الخطوات التالية:

#### 1. التحضير
```bash
# افتح الملف
# اقرأ الكود الحالي
# حدد العناصر التي تحتاج تحديث
```

#### 2. تحديث الألوان
```dart
// قبل
color: Color(0xFF6B46C1),

// بعد
color: theme.colorScheme.primary,
```

#### 3. تحديث الخطوط
```dart
// قبل
TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

// بعد
theme.textTheme.titleLarge,
```

#### 4. تحديث الأزرار
```dart
// قبل
ElevatedButton(child: Text('زر')),

// بعد
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 64),
    backgroundColor: theme.colorScheme.primary,
  ),
  child: Text(
    'زر',
    style: theme.textTheme.labelLarge,
  ),
)
```

#### 5. استبدال Firebase
```dart
// قبل
import 'package:firebase_auth/firebase_auth.dart';
final user = FirebaseAuth.instance.currentUser;

// بعد
// TODO: Backend Integration - Remove Firebase
// import 'package:firebase_auth/firebase_auth.dart';
// TODO: Backend Integration - Get current user from API
```

#### 6. اختبار
- تشغيل التطبيق
- التحقق من الألوان
- التحقق من الخطوط
- التحقق من التنقل
- التحقق من عدم وجود أخطاء

---

## 📊 جدول التتبع

| الصفحة | الدور | الألوان | الخطوط | الأزرار | Firebase | الحالة |
|--------|-------|---------|--------|---------|----------|--------|
| patient_dashboard.dart | Patient | ✅ | ✅ | ✅ | ✅ | ✅ |
| patient_appointment_management.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_medication_management.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_profile.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_medical_record.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_lab_results_review.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_transportation.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_publication.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_home.dart | Patient | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| home.dart (Doctor) | Doctor | ✅ | ✅ | ✅ | ✅ | ✅ |
| doctor_detail.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| patient_list.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| lab_results_review.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| medical_records.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| medications.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| incoming_requests.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| override_requests.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| lab_test_request.dart | Doctor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| nurse_dashboard.dart | Nurse | ✅ | ✅ | ✅ | ✅ | ✅ |
| nurse_patient_management.dart | Nurse | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| nurse_medication_management.dart | Nurse | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| nurse_appointment_management.dart | Nurse | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| nurse_profile.dart | Nurse | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| (15 صفحة أخرى للممرضين) | Nurse | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |

**Legend**: ✅ مكتمل | ⏳ قيد الانتظار | 🔄 قيد العمل

---

## 🎯 أولويات التحديث

### المرحلة 1: صفحات المرضى الأساسية (أعلى أولوية)
1. ✅ Patient Dashboard (مكتمل)
2. ⏳ Patient Appointment Management
3. ⏳ Patient Medication Management
4. ⏳ Patient Profile

### المرحلة 2: صفحات الأطباء الأساسية
1. ✅ Doctor Dashboard (مكتمل)
2. ⏳ Patient List
3. ⏳ Lab Results Review
4. ⏳ Medications

### المرحلة 3: صفحات الممرضين الأساسية
1. ✅ Nurse Dashboard (مكتمل)
2. ⏳ Nurse Patient Management
3. ⏳ Nurse Medication Management
4. ⏳ Nurse Appointment Management

### المرحلة 4: الصفحات الثانوية
- جميع الصفحات المتبقية

---

## 📝 ملاحظات مهمة

### عند التحديث:
1. ✅ **احتفظ بالهيكل** - لا تُغير البنية العامة إلا للضرورة
2. ✅ **استخدم DESIGN_SYSTEM.md** - كمرجع لجميع الأنماط
3. ✅ **اختبر بعد كل تغيير** - تأكد أن كل شيء يعمل
4. ✅ **أضف TODO markers** - في كل مكان يحتاج Backend
5. ✅ **حافظ على البيانات التجريبية** - لعرض الواجهات

### الأخطاء الشائعة التي يجب تجنبها:
- ❌ تغيير الهيكل العام للصفحة
- ❌ استخدام ألوان hardcoded
- ❌ نسيان TODO markers
- ❌ حذف الوظائف الموجودة
- ❌ تجاهل Theme
- ❌ أزرار صغيرة للمرضى

---

## ✅ قائمة فحص نهائية

قبل اعتبار الصفحة مكتملة:

- [ ] استخدام `theme.colorScheme.primary/secondary`
- [ ] استخدام `theme.textTheme.___`
- [ ] أزرار 64px للمرضى، 48px للكادر
- [ ] مسافات 20px padding للمرضى
- [ ] TODO markers واضحة
- [ ] بيانات تجريبية موجودة
- [ ] لا أخطاء lint
- [ ] لا أخطاء build
- [ ] التنقل يعمل
- [ ] الألوان هادئة ومريحة
- [ ] النصوص كبيرة وواضحة

---

**تم إنشاؤه**: 4 يناير 2026  
**الحالة**: 3 من 36 صفحة مكتملة (8%)  
**المرجع**: [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)

