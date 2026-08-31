// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مُفرِّغ';

  @override
  String get appSubtitle => 'مستخرج صفحات السبرايت';

  @override
  String get home => 'الرئيسية';

  @override
  String get recentProjects => 'المشاريع الأخيرة';

  @override
  String get noRecentProjects =>
      'لا توجد مشاريع حديثة.\nاستورد صفحة سبرايت للبدء.';

  @override
  String get newSpriteSheet => 'صفحة سبرايت جديدة';

  @override
  String get dropImageHere => 'أسقط الصورة هنا';

  @override
  String get orBrowse => 'أو تصفح الملفات';

  @override
  String get importImage => 'استيراد صورة';

  @override
  String get openRecentProject => 'فتح مشروع حديث';

  @override
  String get clearHistory => 'مسح السجل';

  @override
  String get workspace => 'مساحة العمل';

  @override
  String get originalSheet => 'الصفحة الأصلية';

  @override
  String get detectedElements => 'العناصر المكتشفة';

  @override
  String get properties => 'الخصائص';

  @override
  String get processing => 'جارٍ المعالجة…';

  @override
  String get stepRemovingBackground => 'إزالة الخلفية…';

  @override
  String get stepDetectingElements => 'اكتشاف العناصر…';

  @override
  String get stepExtractingCrops => 'استخراج المقاطع…';

  @override
  String get stepFeathering => 'تنعيم الحواف…';

  @override
  String get stepDone => 'اكتمل';

  @override
  String elementsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصراً مكتشفاً',
      few: '$count عناصر مكتشفة',
      two: 'عنصران مكتشفان',
      one: 'عنصر واحد مكتشف',
      zero: 'لم يُكتشف أي عنصر',
    );
    return '$_temp0';
  }

  @override
  String get noElementsFound =>
      'لم يُكتشف أي عنصر.\nجرّب ضبط حساسية الاكتشاف في الإعدادات.';

  @override
  String get element => 'عنصر';

  @override
  String elementLabel(String number) {
    return 'عنصر $number';
  }

  @override
  String get deleteElement => 'حذف';

  @override
  String get mergeElements => 'دمج مع…';

  @override
  String get splitElement => 'تقسيم';

  @override
  String get renameElement => 'إعادة تسمية';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get save => 'حفظ';

  @override
  String get background => 'الخلفية';

  @override
  String get transparent => 'شفاف';

  @override
  String get customColor => 'لون مخصص';

  @override
  String get globalBackground => 'الخلفية العامة';

  @override
  String get perElementOverride => 'تخصيص لكل عنصر';

  @override
  String get useGlobal => 'استخدام العام';

  @override
  String get clearOverride => 'إزالة التخصيص';

  @override
  String get export => 'تصدير';

  @override
  String get exportAll => 'تصدير الكل';

  @override
  String exportSelected(int count) {
    return 'تصدير المحدد ($count)';
  }

  @override
  String get chooseFolder => 'اختر مجلداً';

  @override
  String get exportFolder => 'مجلد التصدير';

  @override
  String get namingScheme => 'نظام التسمية';

  @override
  String get namingSequential => 'تسلسلي (element_001)';

  @override
  String get namingPosition => 'حسب الموضع (row1_col3)';

  @override
  String get namingCustom => 'أسماء مخصصة';

  @override
  String exportSuccess(int count, String folder) {
    return 'تم تصدير $count ملفات إلى $folder';
  }

  @override
  String exportError(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get openFolder => 'فتح المجلد';

  @override
  String get settings => 'الإعدادات';

  @override
  String get detectionSensitivity => 'حساسية الاكتشاف';

  @override
  String get detectionSensitivityHint =>
      'كلما زادت القيمة، كانت إزالة الخلفية أكثر عدوانية';

  @override
  String get minimumElementSize => 'الحجم الأدنى للعنصر';

  @override
  String get minimumElementSizeHint =>
      'العناصر الأصغر من هذا الحجم تُعامل كضجيج وتُهمل';

  @override
  String get gapErosion => 'تآكل الفجوة';

  @override
  String get gapErosionHint => 'يفصل العناصر المتلامسة أو المتداخلة';

  @override
  String get edgeFeathering => 'تنعيم الحواف';

  @override
  String get edgeFeatheringHint =>
      'يجعل حواف العناصر أكثر نعومة للحفاظ على تدرج الألوان';

  @override
  String get elementPadding => 'الحشو';

  @override
  String get elementPaddingHint => 'بكسلات إضافية تُضاف حول إطار كل عنصر';

  @override
  String get language => 'اللغة';

  @override
  String get defaultBackground => 'الخلفية الافتراضية';

  @override
  String get defaultExportFolder => 'مجلد التصدير الافتراضي';

  @override
  String get browse => 'تصفح';

  @override
  String get resetDefaults => 'إعادة الإعدادات الافتراضية';

  @override
  String errorImageLoad(String error) {
    return 'فشل تحميل الصورة: $error';
  }

  @override
  String errorProcessing(String error) {
    return 'فشلت المعالجة: $error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get retryDetection => 'إعادة المحاولة';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get detectionFailureTitle => 'تعذر اكتشاف عناصر منفصلة';

  @override
  String get detectionFailureBody =>
      'تعذر اكتشاف عناصر منفصلة في هذه الورقة — جرّب تعديل حساسية الكشف أو تأكد أن الخلفية شفافة أو موحدة اللون.';

  @override
  String get confirmDeleteElement => 'حذف هذا العنصر؟';

  @override
  String get confirmDeleteElementBody => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get confirmClearHistory => 'مسح كل المشاريع الأخيرة؟';

  @override
  String get reprocess => 'إعادة معالجة الصفحة';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get pixels => 'بكسل';

  @override
  String get percent => '%';

  @override
  String get boundingBox => 'إطار الحدود';

  @override
  String get width => 'العرض';

  @override
  String get height => 'الارتفاع';

  @override
  String get position => 'الموضع';

  @override
  String get size => 'الحجم';

  @override
  String get developer => 'المطور';

  @override
  String get developerName => 'حسام حسن مجرشي';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';
}
