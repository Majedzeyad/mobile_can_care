# 🎨 دليل تصميم CanCare الشامل
## مبادئ التصميم المُطبَّقة على جميع الصفحات

---

## 📋 جدول المحتويات

1. [المبادئ العامة](#المبادئ-العامة)
2. [نظام الألوان](#نظام-الألوان)
3. [الخطوط والأحجام](#الخطوط-والأحجام)
4. [العناصر والمكونات](#العناصر-والمكونات)
5. [الأنماط المُوحدة لكل نوع صفحة](#الأنماط-الموحدة)
6. [استبدال Firebase بـTODO](#استبدال-firebase)
7. [قائمة فحص التصميم](#قائمة-فحص)

---

## 🎯 المبادئ العامة

### 1. الراحة النفسية والبصرية 💚
**للمرضى (الأولوية القصوى)**:
- ✅ استخدم الألوان الهادئة من `AppTheme.patient___`
- ✅ مسافات بيضاء سخية (20-40 بكسل بين الأقسام)
- ✅ تدرجات لونية ناعمة في الخلفيات
- ✅ رسائل إيجابية ومطمئنة

**للأطباء والممرضين**:
- ✅ ألوان احترافية وواضحة
- ✅ تنظيم بصري محكم
- ✅ كثافة معلومات معتدلة

### 2. سهولة الاستخدام 👆
- ✅ أزرار كبيرة (64 بكسل للمرضى، 48 بكسل للكادر)
- ✅ خطوط كبيرة وواضحة (19-36 بكسل للمرضى)
- ✅ أيقونات بديهية وملونة
- ✅ تباين عالٍ (WCAG 2.1 AA)
- ✅ مساحات لمس واسعة

### 3. ترتيب الأولويات 📊
**للمرضى**:
1. المعلومات الطبية الأهم (المواعيد، الأدوية)
2. الإجراءات السريعة
3. زر SOS (إن وجد)
4. المعلومات التفصيلية

**للكادر الطبي**:
1. المهام اليومية
2. الإحصائيات السريعة
3. الإجراءات المتكررة
4. التفاصيل الإضافية

---

## 🎨 نظام الألوان

### ألوان المرضى (Patient Theme)

```dart
// الألوان الأساسية
theme.colorScheme.primary        // #81C784 (أخضر ناعم)
theme.colorScheme.secondary      // #5B9AA0 (فيروزي)
theme.scaffoldBackgroundColor    // #F7FBF9 (خلفية نعناعية خفيفة)

// للعناصر التفاعلية
Container(
  color: theme.colorScheme.primary.withOpacity(0.1),  // خلفية زر خفيفة
)

Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primary.withOpacity(0.1),
        theme.colorScheme.secondary.withOpacity(0.05),
      ],
    ),
  ),
)
```

### ألوان الأطباء (Doctor Theme)

```dart
theme.colorScheme.primary        // #5B9AA0 (فيروزي احترافي)
theme.colorScheme.secondary      // #42A5F5 (أزرق واضح)
theme.scaffoldBackgroundColor    // #FAFAFA (أبيض ناعم)
```

### ألوان الممرضين (Nurse Theme)

```dart
theme.colorScheme.primary        // #9575CD (بنفسجي ناعم)
theme.colorScheme.secondary      // #81C784 (أخضر للنجاح)
theme.scaffoldBackgroundColor    // #F5F5F8 (رمادي ناعم)
```

### ألوان دلالية موحدة

```dart
// النجاح
Color(0xFF81C784)  // أخضر ناعم

// التحذير
Color(0xFFFFB74D)  // برتقالي دافئ

// الخطأ
Color(0xFFE57373)  // أحمر ناعم

// المعلومات
Color(0xFF64B5F6)  // أزرق فاتح

// الطوارئ
Color(0xFFEF5350)  // أحمر ملطّف

// مستويات الأولوية (للممرضين)
final priorityColors = {
  'عاجلة': Color(0xFFEF5350),  // أحمر
  'عالية': Color(0xFFFFB74D),  // برتقالي
  'عادية': Color(0xFF81C784),  // أخضر
};
```

---

## 📝 الخطوط والأحجام

### للمرضى (أكبر للراحة)

```dart
// العناوين الرئيسية
theme.textTheme.displayLarge      // 36px, bold
theme.textTheme.headlineLarge     // 26px, bold

// العناوين الفرعية
theme.textTheme.titleLarge        // 20px, semi-bold
theme.textTheme.titleMedium       // 18px, medium

// النصوص الأساسية
theme.textTheme.bodyLarge         // 19px, regular (أكبر للقراءة)
theme.textTheme.bodyMedium        // 18px, regular

// نصوص الأزرار
theme.textTheme.labelLarge        // 18px, bold
```

### للأطباء والممرضين (معتدل)

```dart
// العناوين
theme.textTheme.headlineMedium    // 20-18px, bold

// النصوص
theme.textTheme.bodyLarge         // 16-15px, regular

// الأزرار
theme.textTheme.labelLarge        // 15-14px, semi-bold
```

### المسافة بين الأسطر

```dart
// للمرضى
TextStyle(
  fontSize: 19,
  height: 1.7,  // مسافة كبيرة للراحة
)

// للكادر الطبي
TextStyle(
  fontSize: 15,
  height: 1.5,  // مسافة معتدلة
)
```

---

## 🧩 العناصر والمكونات

### 1. الأزرار (Buttons)

#### أزرار أساسية للمرضى

```dart
// زر أساسي كبير
ElevatedButton(
  onPressed: () {
    // TODO: Backend Integration - Handle action
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 64),  // عرض كامل، 64 بكسل ارتفاع
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),  // حواف ناعمة
    ),
    elevation: 2,
  ),
  child: Text(
    'نص الزر',
    style: theme.textTheme.labelLarge,
  ),
)

// زر ثانوي (Outlined)
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: theme.colorScheme.primary,
    minimumSize: const Size(double.infinity, 64),
    side: BorderSide(color: theme.colorScheme.primary, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('نص الزر'),
)

// زر أيقونة كبير
IconButton(
  icon: Icon(
    Icons.notifications_outlined,
    size: 32,  // أيقونة كبيرة
    color: theme.colorScheme.primary,
  ),
  onPressed: () {},
  constraints: const BoxConstraints(
    minWidth: 56,
    minHeight: 56,
  ),
)
```

#### أزرار للكادر الطبي

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),  // 48 بكسل للكادر
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  child: Text('زر'),
)
```

### 2. الكروت (Cards)

#### كرت معلومات للمرضى

```dart
Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.all(24),  // حشوة سخية
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),  // حواف ناعمة جداً
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // محتوى الكرت
    ],
  ),
)

// كرت مُميز (Featured Card)
Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primary.withOpacity(0.1),
        theme.colorScheme.secondary.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: theme.colorScheme.primary.withOpacity(0.3),
      width: 2,
    ),
  ),
  child: // محتوى
)
```

#### كرت للكادر الطبي

```dart
Container(
  padding: const EdgeInsets.all(16),  // حشوة معتدلة
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: // محتوى
)
```

### 3. حقول الإدخال (Input Fields)

```dart
// للمرضى
TextField(
  style: theme.textTheme.bodyLarge,  // خط كبير
  decoration: InputDecoration(
    hintText: 'ابحث...',
    hintStyle: theme.textTheme.bodyLarge?.copyWith(
      color: Colors.grey[400],
    ),
    prefixIcon: Icon(
      Icons.search,
      size: 28,  // أيقونة كبيرة
      color: theme.colorScheme.primary,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 20,  // حشوة كبيرة
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: 2,
      ),
    ),
  ),
)
```

### 4. قوائم العناصر (Lists)

```dart
// عنصر قائمة للمرضى
ListTile(
  contentPadding: const EdgeInsets.all(20),  // حشوة كبيرة
  leading: Container(
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
  title: Text(
    'عنوان',
    style: theme.textTheme.titleLarge,
  ),
  subtitle: Text(
    'نص فرعي',
    style: theme.textTheme.bodyMedium,
  ),
  trailing: Icon(
    Icons.arrow_forward_ios,
    size: 24,
    color: theme.colorScheme.primary,
  ),
  onTap: () {},
)
```

### 5. شريط التنقل السفلي (Bottom Navigation)

```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() => _currentIndex = index);
    // التنقل...
  },
  type: BottomNavigationBarType.fixed,
  selectedItemColor: theme.colorScheme.primary,
  unselectedItemColor: Colors.grey[600],
  selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  unselectedLabelStyle: theme.textTheme.labelSmall,
  selectedIconTheme: const IconThemeData(
    size: 28,  // أيقونة أكبر للعنصر المحدد
  ),
  unselectedIconTheme: const IconThemeData(
    size: 24,
  ),
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    // المزيد...
  ],
)
```

---

## 📄 الأنماط المُوحدة لكل نوع صفحة

### نمط صفحة المريض

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),  // حشوة سخية
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (إن لم يكن AppBar)
            _buildHeader(theme),
            const SizedBox(height: 32),  // مسافة كبيرة

            // 2. رسالة أو معلومة مُميزة
            _buildFeaturedSection(theme),
            const SizedBox(height: 24),

            // 3. المحتوى الرئيسي
            _buildMainContent(theme),
            const SizedBox(height: 24),

            // 4. محتوى ثانوي
            _buildSecondaryContent(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigation(theme),
  );
}

Widget _buildHeader(ThemeData theme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'عنوان الصفحة',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          size: 32,
          color: theme.colorScheme.primary,
        ),
        onPressed: () {},
      ),
    ],
  );
}
```

### نمط صفحة الطبيب

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),  // حشوة معتدلة
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            
            // محتوى منظم وفعال
            _buildStatsSection(theme),
            const SizedBox(height: 16),
            
            _buildActionsGrid(theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigation(theme),
  );
}
```

### نمط صفحة الممرض

```dart
// مشابه للطبيب، مع التركيز على المهام
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            
            // قائمة مهام بمستويات أولوية
            _buildTasksList(theme),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigation(theme),
  );
}

Widget _buildTasksList(ThemeData theme) {
  return Column(
    children: _tasks.map((task) {
      final priorityColor = _getPriorityColor(task['priority']);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: priorityColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.task,
                color: priorityColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'],
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    task['time'],
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Badge للأولوية
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task['priority'],
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

Color _getPriorityColor(String priority) {
  switch (priority) {
    case 'عاجلة':
      return const Color(0xFFEF5350);
    case 'عالية':
      return const Color(0xFFFFB74D);
    default:
      return const Color(0xFF81C784);
  }
}
```

---

## 🔌 استبدال Firebase بـTODO

### القاعدة الأساسية:
**احذف جميع استدعاءات Firebase واستبدلها بـTODO markers**

### أمثلة التحويل:

#### قبل:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> loadAppointments() async {
  final user = FirebaseAuth.instance.currentUser;
  final snapshot = await FirebaseFirestore.instance
      .collection('appointments')
      .where('patientId', isEqualTo: user?.uid)
      .get();
      
  setState(() {
    _appointments = snapshot.docs.map((doc) => doc.data()).toList();
  });
}
```

#### بعد:
```dart
// TODO: Backend Integration - Remove Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

Future<void> loadAppointments() async {
  // TODO: Backend Integration - Fetch appointments from API
  // Replace this dummy data with actual API call
  setState(() {
    _appointments = [
      {
        'date': 'Today',
        'time': '10:30 AM',
        'doctor': 'Dr. Smith',
        'room': 'Room 202',
      },
      // المزيد من البيانات التجريبية...
    ];
  });
  
  /* FIREBASE CODE - TODO: Restore when backend is ready
  final user = FirebaseAuth.instance.currentUser;
  final snapshot = await FirebaseFirestore.instance
      .collection('appointments')
      .where('patientId', isEqualTo: user?.uid)
      .get();
      
  setState(() {
    _appointments = snapshot.docs.map((doc) => doc.data()).toList();
  });
  */
}
```

### أماكن TODO الشائعة:

```dart
// 1. في initState
@override
void initState() {
  super.initState();
  // TODO: Backend Integration - Load data from API
  _loadData();
}

// 2. في متغيرات البيانات
// TODO: Backend Integration - Replace with actual data from API
final List<Map<String, dynamic>> _items = [
  // بيانات تجريبية
];

// 3. في دوال الحفظ
Future<void> _saveData() async {
  // TODO: Backend Integration - Save data to API
  // Currently using local state only
}

// 4. في دوال الرفع (Upload)
Future<void> _uploadFile() async {
  // TODO: Backend Integration - Upload file to server
  // TODO: Firebase Storage integration needed
}

// 5. في المصادقة
void _login() {
  // TODO: Backend Integration - Implement authentication
  Navigator.push(...);
}
```

---

## ✅ قائمة فحص التصميم

### لكل صفحة، تأكد من:

#### الألوان
- [ ] استخدام `theme.colorScheme.primary/secondary`
- [ ] خلفية من `theme.scaffoldBackgroundColor`
- [ ] تدرجات لونية ناعمة للعناصر المُميزة
- [ ] ألوان دلالية واضحة (أخضر للنجاح، أحمر للخطأ)

#### الخطوط
- [ ] استخدام `theme.textTheme.___` لجميع النصوص
- [ ] العناوين الرئيسية كبيرة (24-36 بكسل للمرضى)
- [ ] النصوص الأساسية قابلة للقراءة (18-19 بكسل للمرضى)
- [ ] تباين عالٍ بين النص والخلفية

#### الأزرار
- [ ] ارتفاع 64 بكسل للمرضى، 48 بكسل للكادر
- [ ] حشوة سخية (20 بكسل أفقي، 20 بكسل رأسي للمرضى)
- [ ] حواف ناعمة (16 بكسل border radius للمرضى)
- [ ] أيقونات كبيرة وواضحة (28-32 بكسل)

#### المسافات
- [ ] حشوة الصفحة 20 بكسل للمرضى، 16 بكسل للكادر
- [ ] مسافة 24-32 بكسل بين الأقسام الرئيسية
- [ ] مسافة 16 بكسل بين العناصر المتعلقة
- [ ] مساحات بيضاء سخية حول النصوص المهمة

#### الكروت
- [ ] ظل ناعم (blur: 8-12, offset: (0, 2-4))
- [ ] حواف ناعمة (16-20 بكسل border radius للمرضى)
- [ ] حدود ملونة خفيفة (2 بكسل، opacity 0.2-0.3)
- [ ] حشوة داخلية سخية (20-24 بكسل للمرضى)

#### Firebase/Backend
- [ ] حذف جميع imports Firebase
- [ ] إضافة TODO markers واضحة
- [ ] استخدام بيانات تجريبية
- [ ] تعليق الكود القديم بين `/* */` مع TODO

#### التنقل
- [ ] شريط تنقل سفلي واضح
- [ ] أيقونات كبيرة (24-28 بكسل)
- [ ] نصوص واضحة للتبويبات
- [ ] تمييز التبويب المحدد بلون مختلف

#### الرسائل
- [ ] رسائل إيجابية ومطمئنة للمرضى
- [ ] رسائل واضحة ومباشرة للكادر
- [ ] رسائل خطأ لطيفة وغير مخيفة
- [ ] رسائل نجاح مشجعة

---

## 🎨 أمثلة مُطبَّقة

### مثال كامل: صفحة المواعيد للمرضى

```dart
import 'package:flutter/material.dart';

class PatientAppointmentPage extends StatefulWidget {
  const PatientAppointmentPage({super.key});

  @override
  State<PatientAppointmentPage> createState() => _PatientAppointmentPageState();
}

class _PatientAppointmentPageState extends State<PatientAppointmentPage> {
  // TODO: Backend Integration - Replace with API data
  final List<Map<String, dynamic>> _appointments = [
    {
      'doctor': 'د. أحمد',
      'specialty': 'أورام',
      'date': 'اليوم',
      'time': '10:00 ص',
      'room': 'غرفة 202',
      'type': 'فحص دوري',
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Backend Integration - Load appointments from API
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    // TODO: Backend Integration - Fetch from API
    // Currently using dummy data above
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme),
              const SizedBox(height: 32),

              // رسالة ترحيبية
              _buildWelcomeCard(theme),
              const SizedBox(height: 24),

              // قائمة المواعيد
              _buildAppointmentsList(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'مواعيدي',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            // TODO: Backend Integration - Add new appointment
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لديك ${_appointments.length} موعد قادم',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'لا تنسى مراجعة مواعيدك',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواعيد القادمة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._appointments.map((appointment) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['doctor'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appointment['specialty'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                theme,
                Icons.calendar_today,
                '${appointment['date']} - ${appointment['time']}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.room,
                appointment['room'],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.medical_services,
                appointment['type'],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
```

---

## 📝 ملاحظات نهائية

### الأولويات:
1. **راحة المريض أولاً** - جميع القرارات التصميمية يجب أن تصب في مصلحة راحة المريض
2. **الوضوح** - كل عنصر يجب أن يكون واضح الغرض
3. **البساطة** - تجنب التعقيد والفوضى البصرية
4. **الإيجابية** - الرسائل والألوان يجب أن تبعث الطمأنينة

### عند التطوير:
- استخدم هذا الدليل كمرجع لجميع الصفحات
- حافظ على الاتساق عبر التطبيق
- اختبر على شاشات مختلفة
- راجع إمكانية الوصول (Accessibility)

### عند التكامل:
- ابحث عن TODO markers
- استبدل البيانات التجريبية بـAPI calls
- احتفظ بالتصميم كما هو
- اختبر جميع الوظائف

---

**تم إنشاؤه بـ ❤️ لراحة مرضى السرطان وعائلاتهم**

*"التصميم الجيد هو التصميم المريح"*

