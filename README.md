# مُفرِّغ — Mufarrigh

> **أداة ذكية لاستخراج وقص صفحات السبرايت وحذف الخلفيات**  
> **Sprite Sheet Extractor & Background Remover**

---

## عربي

**مُفرِّغ (Mufarrigh)** هو تطبيق مفتوح المصدر ومتعدد المنصات مبني باستخدام **Flutter**، مصمم خصيصاً لمطوري الألعاب والمصممين لاستخراج وقص العناصر والرسومات الفردية من صفحات السبرايت (Sprite Sheets) بدقة عالية مع إزالة الخلفيات تلقائياً وتصديرها بصيغة PNG شفافة.

---

### المميزات الرئيسية

- **إزالة ذكية للخلفية**: خوارزمية ملء فيضي (BFS Flood-Fill) متطورة تكشف لون الخلفية السائد وتزيله تلقائياً بدقة مع دعم ضبط الحساسية (Tolerance).
- **فصل العناصر المتلاصقة (Gap Erosion)**: خوارزمية فصل مخصصة لتفكيك العناصر المتلامسة وتحديد حدود كل عنصر بدقة عبر تصنيف المكونات المتصلة (Connected-Component Labeling).
- **تنعيم الحواف (Edge Feathering)**: تنعيم حواف العناصر المستخرجة للحفاظ على جودة الألوان وتدرج الشفافية (Anti-Aliasing).
- **معاينة تفاعلية**: إمكانية التكبير والتصغير (Pan & Zoom) مع خلفية شطرنجية (Checkerboard) تعكس الشفافية الحقيقية لكل عنصر.
- **تحكم كامل بالعناصر**:
  - إعادة تسمية العناصر بشكل مخصص.
  - تحديد لون خلفية عام أو تخصيص لون خلفية لكل عنصر على حدة.
  - حذف وتعديل العناصر غير المرغوبة.
  - اختيار عناصر محددة أو تصدير كافة العناصر دفعة واحدة.
- **تصدير مرن ومتقدم**:
  - تصدير بصيغة PNG عالية الجودة مع قناة ألفا (Alpha Channel).
  - أنظمة تسمية متعددة: تسلسلي (`element_001`)، حسب الموضع (`row1_col3`)، أو أسماء مخصصة.
  - تنظيم المخرجات في مجلدات فرعية تلقائية مبنية على اسم الملف الأصلي.
- **واجهة مستخدم متكيفة (Adaptive Layout)**:
  - تخطيط بثلاثة ألواح متزامنة لبيئات سطح المكتب (Linux, Windows, macOS).
  - تخطيط مبوب وسلس لشاشات الموبايل والأجهزة اللوحية (Android, iOS).
  - دعم السحب والإفلات (Drag & Drop) المباشر لملفات الصور.
- **ثنائي اللغة بالكامل**: دعم أصيل للغة العربية باتجاه من اليمين لليسار (RTL) واللغة الإنجليزية (LTR).
- **محرك Pure Dart**: محرك معالجة صور بيور دارت خفيف وسريع وبدون أي مكتبات C++ خارجية معقدة.

---

### لقطات من التطبيق

#### واجهة التطبيق
<img width="1920" height="1034" alt="Home Screen - Sprite Sheet Extractor" src="https://github.com/user-attachments/assets/666c4e75-cf7a-47ba-96cb-d42a86466fb7" />
<img width="1920" height="1034" alt="Home Screen - Recent Projects" src="https://github.com/user-attachments/assets/b710aee1-6590-46f2-88f1-d94348b2df55" />
<img width="2050" height="1164" alt="Overview Showcase" src="https://github.com/user-attachments/assets/5e11bca3-81a7-43d9-9f24-89d502720045" />
<img width="1920" height="1034" alt="Main Interface" src="https://github.com/user-attachments/assets/31c0fb2f-f422-49f3-98d7-6238e710d153" />

#### داخل التطبيق ومساحة العمل
<img width="1920" height="1034" alt="Workspace - Sheet and Elements Grid" src="https://github.com/user-attachments/assets/12b6283f-20c8-4e49-b7cd-58d91bb50ed4" />

#### المخرجات وعملية التصدير
<img width="2050" height="1164" alt="Export Output Preview 1" src="https://github.com/user-attachments/assets/76bbb8ce-a165-4154-aae2-e62ca8fda700" />
<img width="2050" height="1164" alt="Export Output Preview 2" src="https://github.com/user-attachments/assets/4f4e4fbc-2544-423e-932b-29bba053f00a" />

---

### التقنيات المستخدمة

- **إطار العمل**: [Flutter](https://flutter.dev/) (Material 3)
- **لغة البرمجة**: [Dart](https://dart.dev/)
- **محرك معالجة الصور**: `image` (Pure Dart Image Processing)
- **إدارة الحالة**: `provider`
- **السحب والإفلات**: `desktop_drop`
- **التدويل والتعريب**: `flutter_localizations` و `intl` (ARB files)
- **اختيار الملفات والألوان**: `file_picker`, `flutter_colorpicker`

---

### متطلبات التشغيل

- بيئة عمل **Flutter SDK** (الإصدار 3.13.0 أو أحدث).
- نظام تشغيل مدعوم (Linux, Windows, macOS, Android, iOS).

---

### التثبيت والتشغيل

1. **استنساخ المستودع:**
   ```bash
   git clone https://github.com/hossam-majrashi/mufarrigh.git
   cd mufarrigh
   ```

2. **تثبيت الحزم البرمجية:**
   ```bash
   flutter pub get
   ```

3. **توليد ملفات التعريب (اختياري، يعمل تلقائياً):**
   ```bash
   flutter gen-l10n
   ```

4. **تشغيل التطبيق:**
   - على نظام لينكس (Linux):
     ```bash
     flutter run -d linux
     ```
   - على نظام ويندوز (Windows):
     ```bash
     flutter run -d windows
     ```
   - على نظام أندرويد (Android):
     ```bash
     flutter run -d android
     ```

---

### بناء حزم الإنتاج

- **بناء حزمة أندرويد (APK):**
  ```bash
  flutter build apk --release
  ```

- **بناء تطبيق لينكس (Linux Desktop):**
  ```bash
  flutter build linux --release
  ```

- **بناء تطبيق ويندوز (Windows Desktop):**
  ```bash
  flutter build windows --release
  ```

---

### هيكل المشروع

```
lib/
├── core/
│   ├── engine/          # محرك معالجة الصور ونماذج البيانات (Pure Dart)
│   ├── l10n/            # ملفات التعريب المولدة تلقائياً
│   ├── theme/           # سمات وألوان التطبيق (AppTheme)
│   └── utils/           # أدوات مساعدة (Checkerboard, FileUtils, Logs)
├── features/
│   ├── home/            # الواجهة الرئيسية وسجل المشاريع الأخيرة
│   ├── workspace/       # مساحة العمل وعرض السبرايت وشبكة العناصر
│   ├── settings/        # إعدادات المعالجة واللغة والمطور
│   └── export/          # خدمة ونوافذ تصدير الصور
├── shared/              # عناصر الواجهة المشتركة
├── app.dart             # إعدادات التطبيق والموجهات
└── main.dart            # نقطة البداية
```

---

### المطور

- **المطور**: حسام حسن مجرشي (Hossam Hassan Majrashi)
- **البريد الإلكتروني**: [Hossam.Majrashi@gmail.com](mailto:Hossam.Majrashi@gmail.com)
- **الموقع الإلكتروني**: [hossam-majrashi.github.io/Works](https://hossam-majrashi.github.io/Works/)

---

### الترخيص

هذا المشروع متاح تحت رخصة MIT. راجع ملف [LICENSE](LICENSE) للمزيد من التفاصيل.

---
---

## English

**Mufarrigh (مُفرِّغ)** is an open-source, cross-platform application built with **Flutter**, designed specifically for game developers and graphic artists to extract individual sprites from sheets, automatically remove solid or opaque backgrounds, and export high-quality transparent PNG elements.

---

### Key Features

- **Intelligent Background Removal**: Advanced BFS flood-fill algorithm with automatic mode-based color detection and configurable tolerance.
- **Gap Erosion & Connected-Component Labeling (CCL)**: Separates adjacent or touching sprites before detection, ensuring precise bounding boxes.
- **Edge Feathering & Anti-Aliasing**: Smooths element edges while preserving anti-aliased details.
- **Interactive Workspace**: Pan & zoom controls with true transparency checkerboard preview.
- **Comprehensive Element Control**:
  - Custom renaming per element.
  - Per-element background color override or global workspace background color.
  - Delete or exclude unwanted detections.
  - Multi-select export mode.
- **Flexible Export System**:
  - High-quality transparent PNG output with alpha channels.
  - Multiple naming schemes: Sequential (`element_001`), Positional (`row1_col3`), or Custom.
  - Automatic subfolder organization based on the source image name.
- **Adaptive UI Architecture**:
  - 3-pane synchronized workspace for desktop environments (Linux, Windows, macOS).
  - Clean tabbed interface for mobile devices and tablets (Android, iOS).
  - Drag-and-drop support for easy image importing.
- **Full Internationalization (i18n)**: Native support for Arabic (RTL) and English (LTR).
- **Pure Dart Image Engine**: Lightweight and fast image processing pipeline with zero native C++ build hurdles.

---

### Screenshots

#### Application Interface
<img width="1920" height="1034" alt="Home Screen - Sprite Sheet Extractor" src="https://github.com/user-attachments/assets/666c4e75-cf7a-47ba-96cb-d42a86466fb7" />
<img width="1920" height="1034" alt="Home Screen - Recent Projects" src="https://github.com/user-attachments/assets/b710aee1-6590-46f2-88f1-d94348b2df55" />
<img width="2050" height="1164" alt="Overview Showcase" src="https://github.com/user-attachments/assets/5e11bca3-81a7-43d9-9f24-89d502720045" />
<img width="1920" height="1034" alt="Main Interface" src="https://github.com/user-attachments/assets/31c0fb2f-f422-49f3-98d7-6238e710d153" />

#### Inside the Application & Workspace
<img width="1920" height="1034" alt="Workspace - Sheet and Elements Grid" src="https://github.com/user-attachments/assets/12b6283f-20c8-4e49-b7cd-58d91bb50ed4" />

#### Extracted Outputs & Export Results
<img width="2050" height="1164" alt="Export Output Preview 1" src="https://github.com/user-attachments/assets/76bbb8ce-a165-4154-aae2-e62ca8fda700" />
<img width="2050" height="1164" alt="Export Output Preview 2" src="https://github.com/user-attachments/assets/4f4e4fbc-2544-423e-932b-29bba053f00a" />

---

### Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Material 3)
- **Language**: [Dart](https://dart.dev/)
- **Image Engine**: `image` (Pure Dart image manipulation)
- **State Management**: `provider`
- **Drag and Drop**: `desktop_drop`
- **Localization**: `flutter_localizations` & `intl` (ARB files)
- **File & Color Picking**: `file_picker`, `flutter_colorpicker`

---

### Prerequisites

- **Flutter SDK** (version 3.13.0 or higher).
- A supported operating system (Linux, Windows, macOS, Android, iOS).

---

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hossam-majrashi/mufarrigh.git
   cd mufarrigh
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate localization files (optional, runs automatically on pub get):**
   ```bash
   flutter gen-l10n
   ```

4. **Run the application:**
   - **Linux Desktop:**
     ```bash
     flutter run -d linux
     ```
   - **Windows Desktop:**
     ```bash
     flutter run -d windows
     ```
   - **Android:**
     ```bash
     flutter run -d android
     ```

---

### Building Release Binaries

- **Android APK:**
  ```bash
  flutter build apk --release
  ```

- **Linux Desktop:**
  ```bash
  flutter build linux --release
  ```

- **Windows Desktop:**
  ```bash
  flutter build windows --release
  ```

---

### Project Architecture

```
lib/
├── core/
│   ├── engine/          # Pure-Dart CV pipeline, CCL, and data models
│   ├── l10n/            # Generated localization classes
│   ├── theme/           # Design system tokens and ThemeData (AppTheme)
│   └── utils/           # Utilities (Checkerboard, FileUtils, Logs)
├── features/
│   ├── home/            # Home screen & recent projects history
│   ├── workspace/       # Interactive sheet preview, elements grid & properties
│   ├── settings/        # Processing options, language, developer card
│   └── export/          # Export service and configuration dialog
├── shared/              # Common UI widgets
├── app.dart             # MaterialApp root & routing
└── main.dart            # Application entrypoint
```

---

### Developer

- **Developer**: Hossam Hassan Majrashi (حسام حسن مجرشي)
- **Email**: [Hossam.Majrashi@gmail.com](mailto:Hossam.Majrashi@gmail.com)
- **Portfolio**: [hossam-majrashi.github.io/Works](https://hossam-majrashi.github.io/Works/)

---

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
