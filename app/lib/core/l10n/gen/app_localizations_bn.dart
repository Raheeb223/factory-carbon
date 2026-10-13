// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'BillToGreen';

  @override
  String get navHome => 'হোম';

  @override
  String get navBills => 'বিল';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navSolar => 'সোলার';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get actionSave => 'সংরক্ষণ করুন';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionRetry => 'আবার চেষ্টা করুন';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionContinue => 'চালিয়ে যান';

  @override
  String get actionClose => 'বন্ধ করুন';

  @override
  String get actionAdd => 'যোগ করুন';

  @override
  String get actionUndo => 'ফেরত যান';

  @override
  String get actionClear => 'সব মুছুন';

  @override
  String get syntheticBadge => 'কৃত্রিম ডেটা';

  @override
  String get syntheticBanner =>
      'এই অ্যাপে কৃত্রিম (ডেমো) ডেটা আছে। ফলাফল কোনো বাস্তব কারখানার নয়।';

  @override
  String get unverifiedFactorBadge => 'অযাচাইকৃত ফ্যাক্টর';

  @override
  String get notAvailable => 'তথ্য নেই';

  @override
  String lastUpdated(String time) {
    return 'সর্বশেষ হালনাগাদ $time';
  }

  @override
  String get showingSaved =>
      'সংরক্ষিত ফলাফল দেখানো হচ্ছে। অনলাইনে থাকলে হালনাগাদ করুন।';

  @override
  String get errorGeneric => 'কিছু একটা সমস্যা হয়েছে।';

  @override
  String get errorNetwork =>
      'সার্ভারে সংযোগ করা যায়নি। ইন্টারনেট সংযোগ এবং সেটিংসে সার্ভারের ঠিকানা পরীক্ষা করুন।';

  @override
  String get errorTimeout => 'সার্ভার উত্তর দিতে অনেক সময় নিয়েছে।';

  @override
  String get errorRateLimited =>
      'অনেক বেশি অনুরোধ। একটু অপেক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get errorServer => 'সার্ভারে সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorUnavailable => 'এই সুবিধাটি এখন সার্ভারে চালু নেই।';

  @override
  String get fieldRequired => 'এটি পূরণ করা আবশ্যক';

  @override
  String get invalidNumber => 'সঠিক সংখ্যা লিখুন';

  @override
  String get invalidNonNegative => 'শূন্য বা তার বেশি হতে হবে';

  @override
  String get invalidLatitude => 'অক্ষাংশ -৯০ থেকে ৯০-এর মধ্যে হতে হবে';

  @override
  String get invalidLongitude => 'দ্রাঘিমাংশ -১৮০ থেকে ১৮০-এর মধ্যে হতে হবে';

  @override
  String get invalidFraction => '০ থেকে ১-এর মধ্যে একটি মান লিখুন';

  @override
  String get invalidMonth => 'একটি মাস নির্বাচন করুন';

  @override
  String get onboardingTitle => 'আপনার কারখানা সেট আপ করুন';

  @override
  String get onboardingIntro =>
      'ইউটিলিটি বিল থেকে ক্রেতাদের জন্য কার্বন রিপোর্ট তৈরি করুন, বেশি বিদ্যুৎ ব্যবহারের সতর্কতা পান এবং ছাদে সোলারের সম্ভাবনা অনুমান করুন।';

  @override
  String get factoryNameLabel => 'কারখানার নাম';

  @override
  String get factoryLocationLabel => 'অবস্থান (শহর, জেলা)';

  @override
  String get factoryLatLabel => 'অক্ষাংশ (ঐচ্ছিক)';

  @override
  String get factoryLonLabel => 'দ্রাঘিমাংশ (ঐচ্ছিক)';

  @override
  String get productionUnitLabel => 'আপনার উৎপাদন কীভাবে গোনেন?';

  @override
  String get privacyTitle => 'আপনার ডেটা ও গোপনীয়তা';

  @override
  String get privacyBody =>
      '• কারখানার প্রোফাইল, বিল, উৎপাদন ও রিপোর্ট শুধু এই ফোনেই সংরক্ষিত থাকে।\n• বিল স্ক্যান করলে ছবিটি মান পড়ার জন্য আমাদের সার্ভারে এবং Google-এর Gemini API-তে পাঠানো হয়। পাঠানোর আগে ফোন নিজেই ছাপানো নাম ও ঠিকানা কালো বক্সে ঢেকে দেয়; আপনি দেখে নিয়ে আরও ঢাকতে পারেন।\n• আমাদের সার্ভার আপনার ছবি বা তথ্য সংরক্ষণ করে না। Google তার Gemini API শর্ত অনুযায়ী আপলোড পরিচালনা করে: সার্ভার Google-এর বিনামূল্যের সংস্করণ ব্যবহার করলে Google আপলোড তার পণ্য উন্নয়নে ব্যবহার করতে পারে এবং Google-এর কর্মীরা তা দেখতে পারেন।\n• কার্বন, অপচয়, সোলার ও PDF হিসাবের জন্য প্রয়োজনীয় সংখ্যাগুলো আমাদের সার্ভারে পাঠানো হয়; সেখানে কিছুই সংরক্ষণ করা হয় না।';

  @override
  String get privacyAcknowledge =>
      'আমার ডেটা কীভাবে ব্যবহার হয় তা আমি পড়েছি ও বুঝেছি';

  @override
  String get privacyMustAcknowledge =>
      'গোপনীয়তা নোটিশ পড়েছেন তা টিক দিয়ে নিশ্চিত করুন।';

  @override
  String get onboardingStart => 'শুরু করুন';

  @override
  String get uploadNoticeTitle => 'প্রথম আপলোডের আগে';

  @override
  String get uploadNoticeBody =>
      'বিল পড়ার জন্য ছবিটি আমাদের সার্ভারে এবং Google-এর Gemini API-তে পাঠানো হবে। পাঠানোর আগে ফোন নিজেই ছাপানো নাম ও ঠিকানা কালো বক্সে ঢেকে দেয়, আর আপনি আরও কিছু ঢাকতে পারেন। আমাদের সার্ভারে ছবি সংরক্ষণ করা হয় না। Google-এর বিনামূল্যের সংস্করণে Google আপলোড তার পণ্য উন্নয়নে ব্যবহার করতে পারে এবং কর্মীরা তা দেখতে পারেন।';

  @override
  String get uploadNoticeAccept => 'বুঝেছি, চালিয়ে যান';

  @override
  String get homeLatestReport => 'সর্বশেষ কার্বন রিপোর্ট';

  @override
  String get homeNoReport =>
      'এখনও কোনো রিপোর্ট নেই। বিল যোগ করুন বা পুরোনো তথ্য ইমপোর্ট করুন, তারপর রিপোর্ট খুলুন।';

  @override
  String get homeQuickActions => 'দ্রুত যান';

  @override
  String get homeImportHistory => 'পুরোনো তথ্য ইমপোর্ট (CSV)';

  @override
  String get homeProduction => 'উৎপাদন';

  @override
  String get homeWaste => 'অস্বাভাবিক বিদ্যুৎ ব্যবহার';

  @override
  String get homeCarbon => 'কার্বন রিপোর্ট';

  @override
  String homeBillsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি বিল সংরক্ষিত',
      zero: 'কোনো বিল সংরক্ষিত নেই',
    );
    return '$_temp0';
  }

  @override
  String get addBillTitle => 'বিল যোগ করুন';

  @override
  String get addBillCamera => 'ছবি তুলুন';

  @override
  String get addBillGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get addBillManual => 'হাতে লিখুন (ছবি ছাড়া)';

  @override
  String get addBillManualHint =>
      'ডিজেলের রসিদ, মিটারবিহীন গ্যাস বা ছবি পড়া না গেলে।';

  @override
  String get cropTitle => 'কিনারা কাটবেন? (ইচ্ছা হলে)';

  @override
  String get cropReminder =>
      'নাম কেটে বাদ দিতে হবে না: পরের ধাপে নাম ও ঠিকানা নিজে থেকেই ঢেকে যাবে। বিলের চারপাশে টেবিল বা মেঝে বেশি দেখা গেলে তবেই কাটুন।';

  @override
  String get preparingImage => 'ছবি প্রস্তুত হচ্ছে…';

  @override
  String uploadProgress(String percent) {
    return 'আপলোড হচ্ছে $percent%';
  }

  @override
  String get uploadReading => 'মান পড়া হচ্ছে। এক মিনিট পর্যন্ত লাগতে পারে।';

  @override
  String get uploadFailedTitle => 'বিলটি পড়া যায়নি';

  @override
  String get uploadEnterManually => 'এর বদলে হাতে লিখুন';

  @override
  String get reviewTitle => 'মানগুলো যাচাই করুন';

  @override
  String get reviewIntro =>
      'মানগুলো স্বয়ংক্রিয়ভাবে পড়া হয়েছে। প্রতিটি মান ছবির সাথে মিলিয়ে দেখুন। হলুদ চিহ্নিত ঘরে বিশেষ মনোযোগ দিন।';

  @override
  String get reviewManualIntro => 'আপনার বিল বা রসিদ থেকে মানগুলো লিখুন।';

  @override
  String get lowConfidence =>
      'নিশ্চিতভাবে পড়া যায়নি: ছবির সাথে মিলিয়ে দেখুন';

  @override
  String get fieldBillType => 'বিলের ধরন';

  @override
  String get billTypeElectricity => 'বিদ্যুৎ';

  @override
  String get billTypeGas => 'গ্যাস';

  @override
  String get billTypeDiesel => 'ডিজেল';

  @override
  String get billTypeUnknown => 'অজানা';

  @override
  String get fieldUtilityName => 'ইউটিলিটি / সরবরাহকারী';

  @override
  String get fieldBillingMonth => 'বিলের মাস';

  @override
  String get fieldPeriodStart => 'সময়কালের শুরু';

  @override
  String get fieldPeriodEnd => 'সময়কালের শেষ';

  @override
  String get fieldConsumedUnits => 'ব্যবহৃত ইউনিট';

  @override
  String get fieldUnit => 'একক';

  @override
  String get fieldTotalAmount => 'মোট প্রদেয় (টাকা)';

  @override
  String get fieldTariffCode => 'ট্যারিফ কোড';

  @override
  String get fieldSanctionedLoad => 'অনুমোদিত লোড (কিলোওয়াট)';

  @override
  String get fieldNotes => 'স্বয়ংক্রিয় পাঠের মন্তব্য';

  @override
  String get notSet => 'নির্ধারিত নয়';

  @override
  String get selectBillType => 'বিলের ধরন নির্বাচন করুন';

  @override
  String unitMismatch(String unit) {
    return 'এই বিলের জন্য একক $unit হতে হবে';
  }

  @override
  String get reviewConfirm => 'আমি বিলের সাথে এই মানগুলো মিলিয়ে দেখেছি';

  @override
  String get reviewMustConfirm =>
      'মানগুলো যাচাই করেছেন তা নিশ্চিত করতে টিক দিন।';

  @override
  String get duplicateTitle => 'বিলটি হয়তো আগেই যোগ করা হয়েছে';

  @override
  String duplicateBody(String type, String month) {
    return '$month মাসের একটি $type বিল আগেই সংরক্ষিত আছে। এটিও সংরক্ষণ করবেন?';
  }

  @override
  String get duplicateSaveAnyway => 'তবুও সংরক্ষণ করুন';

  @override
  String get billSaved => 'বিল সংরক্ষিত হয়েছে';

  @override
  String get imageWillBeDeleted =>
      'সংরক্ষণের পর ছবিটি এই ফোন থেকে মুছে ফেলা হবে।';

  @override
  String get imageWillBeKept => 'ছবিটি এই ফোনে রাখা হবে (সেটিংস)।';

  @override
  String get warnUnknownBillType => 'বিলের ধরন চেনা যায়নি। নির্বাচন করুন।';

  @override
  String get warnPeriodEndBeforeStart => 'সময়কালের শেষ তারিখ শুরুর আগে।';

  @override
  String get warnUnusualPeriodLength =>
      'মাসিক বিলের জন্য সময়কালের দৈর্ঘ্য অস্বাভাবিক।';

  @override
  String get warnMonthPeriodMismatch =>
      'বিলের মাস সময়কালের শেষ তারিখের সাথে মিলছে না।';

  @override
  String get warnUnitsNotPositive => 'ব্যবহৃত ইউনিট শূন্যের বেশি হওয়া উচিত।';

  @override
  String get warnUnitsAboveCeiling =>
      'ব্যবহৃত ইউনিট অস্বাভাবিক বেশি। যাচাই করুন।';

  @override
  String get warnUnitTypeMismatch => 'এই বিলের জন্য এককটি অস্বাভাবিক।';

  @override
  String get warnPriceOutOfBand =>
      'প্রতি ইউনিট মূল্য স্বাভাবিক সীমার বাইরে। ইউনিট ও টাকার পরিমাণ যাচাই করুন।';

  @override
  String get warnLowConfidence =>
      'এই মানটি নিশ্চিতভাবে পড়া যায়নি। ছবির সাথে মিলিয়ে দেখুন।';

  @override
  String get billsTitle => 'বিল';

  @override
  String get billsEmpty =>
      'এখনও কোনো বিল নেই। বিল যোগ করুন বা পুরোনো তথ্য ইমপোর্ট করুন।';

  @override
  String get billOriginImage => 'ছবি থেকে';

  @override
  String get billOriginManual => 'হাতে লেখা';

  @override
  String get billOriginImported => 'ইমপোর্ট করা (বিলের ছবি থেকে নয়)';

  @override
  String get billOriginDemo => 'কৃত্রিম';

  @override
  String get billEdited => 'সম্পাদিত';

  @override
  String get deleteBillConfirm => 'এই বিলটি মুছবেন?';

  @override
  String get editBillTitle => 'বিল সম্পাদনা';

  @override
  String get productionTitle => 'উৎপাদন';

  @override
  String get productionEmpty => 'এখনো উৎপাদনের তথ্য নেই।';

  @override
  String get productionMonth => 'মাস';

  @override
  String productionUnits(String unit) {
    return 'কত $unit তৈরি করলেন?';
  }

  @override
  String get productionAdd => 'উৎপাদন যোগ করুন';

  @override
  String get productionReplaceNote =>
      'আগে থেকে থাকা মাস সংরক্ষণ করলে আগের মান প্রতিস্থাপিত হবে।';

  @override
  String get importTitle => 'পুরোনো তথ্য ইমপোর্ট';

  @override
  String get importIntro =>
      'টেমপ্লেটে ১২–২৪ মাসের তথ্য লিখুন: মাস, বিদ্যুৎ kWh, ডিজেল লিটার, গ্যাস m³ ও উৎপাদন (বিদ্যুতের খরচ ঐচ্ছিক)। তারপর এখানে ইমপোর্ট করুন।';

  @override
  String get importGetTemplate => 'টেমপ্লেট নিন';

  @override
  String get importPickFile => 'CSV ফাইল বেছে নিন';

  @override
  String importRowsReady(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString মাস ইমপোর্টের জন্য প্রস্তুত',
    );
    return '$_temp0';
  }

  @override
  String get importErrors => 'এই সমস্যাগুলো ঠিক করে আবার ফাইল বেছে নিন:';

  @override
  String get importWarnings => 'সতর্কতা';

  @override
  String get importConfirm => 'ইমপোর্ট';

  @override
  String importDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString মাস ইমপোর্ট হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get importMarked =>
      'ইমপোর্ট করা সারিগুলো \"ইমপোর্ট করা (বিলের ছবি থেকে নয়)\" হিসেবে চিহ্নিত থাকে এবং ডেটার মান অংশে দেখানো হয়।';

  @override
  String get importFewMonths =>
      '১২ মাসের কম: অপচয় যাচাইয়ের জন্য অন্তত ৬ মাস লাগে, পুরো এক বছরের তথ্য হলে ভালো।';

  @override
  String issueMissingColumns(String columns) {
    return 'কলাম নেই: $columns';
  }

  @override
  String get issueNoRows => 'ফাইলে কোনো ডেটা সারি নেই।';

  @override
  String issueBadMonth(String row, String value) {
    return 'সারি $row: মাস \"$value\" অবশ্যই YYYY-MM হতে হবে';
  }

  @override
  String issueBadNumber(String row, String column, String value) {
    return 'সারি $row: $column \"$value\" সংখ্যা নয়';
  }

  @override
  String issueNegative(String row, String column) {
    return 'সারি $row: $column ঋণাত্মক হতে পারে না';
  }

  @override
  String issueDuplicateMonth(String row, String value) {
    return 'সারি $row: মাস $value একাধিকবার আছে';
  }

  @override
  String issueEmptyRow(String row, String value) {
    return 'সারি $row: $value মাসের কোনো মান নেই; বাদ দেওয়া হলো';
  }

  @override
  String issueCostWithoutKwh(String row, String value) {
    return 'সারি $row: $value মাসে kWh ছাড়া খরচ দেওয়া হয়েছে; খরচ বাদ দেওয়া হলো';
  }

  @override
  String get importColMonth => 'মাস';

  @override
  String get importColKwh => 'kWh';

  @override
  String get importColDiesel => 'ডিজেল লি.';

  @override
  String get importColGas => 'গ্যাস m³';

  @override
  String get importColProduction => 'উৎপাদন';

  @override
  String get carbonTitle => 'কার্বন রিপোর্ট';

  @override
  String get carbonCalculate => 'রিপোর্ট হালনাগাদ করুন';

  @override
  String get carbonNoData =>
      'এখনও নিশ্চিত করা কোনো তথ্য নেই। বিল যোগ করুন বা পুরোনো তথ্য ইমপোর্ট করুন।';

  @override
  String get carbonScope1 => 'স্কোপ ১ (ডিজেল + গ্যাস)';

  @override
  String get carbonScope2 => 'স্কোপ ২ (গ্রিড বিদ্যুৎ)';

  @override
  String get carbonTotal => 'মোট';

  @override
  String carbonIntensity(String unit) {
    return 'প্রতি ১,০০০ $unit-এ';
  }

  @override
  String tonnesCo2e(String value) {
    return '$value টন CO₂e';
  }

  @override
  String get carbonMonthly => 'মাসিক নির্গমন';

  @override
  String get carbonPartialMonth =>
      '* আংশিক মাস (কোনো উৎসের তথ্য বা ফ্যাক্টর নেই)। খালি মাসে তথ্য নেই; সেগুলো শূন্য নয়।';

  @override
  String get carbonFactorsTitle => 'নির্গমন ফ্যাক্টর';

  @override
  String get carbonQualityTitle => 'ডেটার মান';

  @override
  String carbonFactorNotSet(String factor) {
    return 'সার্ভারে $factor নির্গমন ফ্যাক্টর নির্ধারিত নেই, তাই এই নির্গমন হিসাব করা হয়নি।';
  }

  @override
  String get factorGrid => 'গ্রিড বিদ্যুৎ';

  @override
  String get factorDiesel => 'ডিজেল';

  @override
  String get factorGas => 'প্রাকৃতিক গ্যাস';

  @override
  String get factorStatusVerified => 'যাচাইকৃত';

  @override
  String factorSource(String source) {
    return 'উৎস: $source';
  }

  @override
  String factorYear(String year) {
    return 'বছর: $year';
  }

  @override
  String get legendElectricity => 'বিদ্যুৎ';

  @override
  String get legendDiesel => 'ডিজেল';

  @override
  String get legendGas => 'গ্যাস';

  @override
  String monthsSummary(String withData, String total, String complete) {
    return '$total মাসের মধ্যে $withData মাসে তথ্য আছে, $complete মাস সম্পূর্ণ';
  }

  @override
  String get exportPdf => 'খসড়া রিপোর্ট (PDF)';

  @override
  String get exportCsv => 'CSV রপ্তানি';

  @override
  String get exportRaw => 'মূল তথ্য রপ্তানি (CSV)';

  @override
  String get exportNeedsResult => 'আগে রিপোর্ট হালনাগাদ করুন।';

  @override
  String get exporting => 'প্রস্তুত হচ্ছে…';

  @override
  String get methodologyTitle => 'পদ্ধতি';

  @override
  String get methodologyBody =>
      'স্কোপ ২ (অবস্থানভিত্তিক) = বিদ্যুৎ kWh × গ্রিড নির্গমন ফ্যাক্টর। স্কোপ ১ = ডিজেল লিটার × ডিজেল ফ্যাক্টর + গ্যাস m³ × গ্যাস ফ্যাক্টর। ফলাফল টন CO2e-তে। প্রতি উৎপাদন এককে নির্গমন শুধু উৎপাদনের তথ্যসহ সম্পূর্ণ মাসের জন্য দেখানো হয়।';

  @override
  String noteMissingData(String source) {
    return 'এই মাসগুলোতে $source-এর তথ্য নেই। এগুলো খালি দেখানো হয়েছে, শূন্য নয়।';
  }

  @override
  String get noteMonthsWithoutData =>
      'এই মাসগুলোতে জ্বালানি বা বিদ্যুতের কোনো তথ্যই নেই।';

  @override
  String get noteMissingProduction =>
      'এই মাসগুলোতে উৎপাদনের তথ্য নেই, তাই প্রতি এককে নির্গমন দেখানো হয়নি।';

  @override
  String get noteMultipleEntries =>
      'এই মাসগুলোতে একই ধরনের একাধিক এন্ট্রি আছে; পরিমাণ যোগ করা হয়েছে। একই বিল দুবার যোগ হয়েছে কি না দেখুন।';

  @override
  String get noteUserEdited =>
      'স্বয়ংক্রিয়ভাবে পড়ার পর কিছু মান আপনি সংশোধন করেছেন।';

  @override
  String get noteManualEntries =>
      'কিছু এন্ট্রি বিলের ছবি ছাড়া হাতে লেখা হয়েছে।';

  @override
  String get noteImportedHistory =>
      'কিছু তথ্য স্প্রেডশিট থেকে ইমপোর্ট করা (বিলের ছবি থেকে নয়)।';

  @override
  String get noteSyntheticData =>
      'কৃত্রিম (ডেমো) তথ্য অন্তর্ভুক্ত। এই ফলাফল কোনো বাস্তব কারখানার নয়।';

  @override
  String get notePlaceholderFactors =>
      'যাচাই না করা (PLACEHOLDER) নির্গমন ফ্যাক্টর ব্যবহৃত হচ্ছে। বাস্তবে জমা দেওয়ার আগে যাচাই করুন।';

  @override
  String get noteIncompleteTotals =>
      'মোট হিসাবে এমন মাস আছে যেখানে কোনো উৎসের তথ্য বা ফ্যাক্টর নেই, তাই প্রকৃত নির্গমনের চেয়ে কম দেখাতে পারে।';

  @override
  String get noteNoData => 'নিশ্চিত করা কোনো বিল বা উৎপাদনের তথ্য নেই।';

  @override
  String get wasteTitle => 'অস্বাভাবিক বিদ্যুৎ ব্যবহার';

  @override
  String get wasteAnalyze => 'এখন যাচাই করুন';

  @override
  String wasteInsufficient(String count, String required) {
    return 'মাত্র $count মাসের বিদ্যুতের তথ্য আছে। অন্তত $required মাস প্রয়োজন।';
  }

  @override
  String get wasteImportPrompt => 'পুরোনো বিল ইমপোর্ট করুন';

  @override
  String get wasteMethodOls =>
      'প্রত্যাশিত ব্যবহার আপনার উৎপাদনের মাত্রার ভিত্তিতে।';

  @override
  String get wasteMethodMad =>
      'কম নির্ভরযোগ্য, উৎপাদনের তথ্য নেই: সাধারণ মাসের সাথে তুলনা।';

  @override
  String get wasteActual => 'প্রকৃত';

  @override
  String get wasteExpected => 'প্রত্যাশিত';

  @override
  String get wasteBand => 'স্বাভাবিক সীমা (৯৫%)';

  @override
  String wasteFlagMessage(String month, String pct, String kwh, String cost) {
    return '$month-এ অস্বাভাবিকতা: উৎপাদনের তুলনায় প্রত্যাশার চেয়ে প্রায় $pct% বেশি বিদ্যুৎ; প্রায় $kwh kWh$cost। এটা প্রমাণিত অপচয় নয়: আগে উৎপাদন, কাজের সময় ও অন্য কারণ দেখে নিন।';
  }

  @override
  String wasteFlagMessageMad(
    String month,
    String pct,
    String kwh,
    String cost,
  ) {
    return '$month-এ অস্বাভাবিকতা: সাধারণ মাসের চেয়ে প্রায় $pct% বেশি বিদ্যুৎ; প্রায় $kwh kWh$cost। এটা প্রমাণিত অপচয় নয়: আগে উৎপাদন, কাজের সময় ও অন্য কারণ দেখে নিন।';
  }

  @override
  String wasteCostPart(String amount) {
    return ', আনুমানিক বাড়তি খরচ প্রায় $amount টাকা';
  }

  @override
  String get wasteNoCost => ' (খরচ অজানা: বিলের টাকার পরিমাণ নেই)';

  @override
  String get wasteNoFlags =>
      'কোনো মাসে স্পষ্টভাবে প্রত্যাশার চেয়ে বেশি বিদ্যুৎ ব্যবহার হয়নি।';

  @override
  String get wasteHowTitle => 'এটি কীভাবে কাজ করে ও এর সীমাবদ্ধতা';

  @override
  String get wasteHowBody =>
      'অন্তত ৬ মাসের বিদ্যুৎ ও উৎপাদনের তথ্য থাকলে অ্যাপটি উৎপাদনের বিপরীতে kWh-এর একটি সরলরেখা নির্ণয় করে। প্রতিটি মাসের জন্য বাকি মাসগুলো থেকে প্রত্যাশিত kWh ও ৯৫% স্বাভাবিক সীমা হিসাব করে। সীমার উপরে থাকা মাস চিহ্নিত হয়।\n\nউৎপাদনের তথ্য না থাকলে প্রতিটি মাসকে আপনার সাধারণ মাসের সাথে তুলনা করে। এটি কম নির্ভরযোগ্য।\n\nসীমাবদ্ধতা:\n• শুধু মাসিক মোট হিসাব ও ছোট নমুনা: ফলাফল কেবল ইঙ্গিত।\n• সাব-মিটার ছাড়া কোন মেশিন বেশি বিদ্যুৎ নিয়েছে তা বলা যায় না।\n• এটি পরিসংখ্যানগত ব্যতিক্রম চিহ্নিত করে; কারণ শনাক্ত করতে পারে না।\n• পণ্যের ধরন, কাজের সময়, আবহাওয়া বা নতুন মেশিনের কারণেও কোনো মাস চিহ্নিত হতে পারে।';

  @override
  String wasteFlaggedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString মাস চিহ্নিত',
      zero: 'কোনো মাস চিহ্নিত হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get solarTitle => 'ছাদে সোলার';

  @override
  String get solarNewPlan => 'নতুন পরিকল্পনা';

  @override
  String get solarNoPlans =>
      'কোনো সংরক্ষিত পরিকল্পনা নেই। শুরু করতে ছাদ আঁকুন।';

  @override
  String get solarDrawHint =>
      'এলাকার নাম খুঁজুন বা GPS বোতাম চাপুন। কাছে জুম করে কারখানার ছাদে ট্যাপ করুন: ছাদের সীমানা নিজে থেকেই আঁকা হবে। সীমানা না এলে ছাদের প্রতিটি কোণে ট্যাপ করুন।';

  @override
  String solarPoints(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি কোণ',
    );
    return '$_temp0';
  }

  @override
  String get solarNeedPoints => 'অন্তত ৩টি কোণে ট্যাপ করুন।';

  @override
  String get solarLayerStreet => 'মানচিত্র';

  @override
  String get solarLayerSatellite => 'স্যাটেলাইট';

  @override
  String get solarSatelliteUnavailable =>
      'স্যাটেলাইট ছবি কনফিগার করা নেই। বেশি জুম করলে মানচিত্রে ভবনের রেখা দেখা যায়।';

  @override
  String get solarParamsTitle => 'সোলারের তথ্য';

  @override
  String get paramUsableRoof => 'ব্যবহারযোগ্য ছাদ (%)';

  @override
  String get paramM2PerKwp => 'প্রতি kW প্যানেলে ছাদের জায়গা (m²)';

  @override
  String get paramPerformanceRatio => 'সিস্টেমের দক্ষতা (%)';

  @override
  String get paramDegradation => 'প্রতি বছর প্যানেলের ক্ষয় (%)';

  @override
  String get paramCapex => 'প্রতি kW-এ সোলার কোম্পানির দাম (টাকা)';

  @override
  String get paramOm => 'বার্ষিক রক্ষণাবেক্ষণ (দামের %)';

  @override
  String get paramPrice => 'আপনার বিদ্যুতের দাম (প্রতি kWh টাকা)';

  @override
  String get paramPriceHint => 'খালি রাখলে: আপনার বিলের গড়';

  @override
  String get paramExportPrice =>
      'বিতরণ কোম্পানি আপনাকে যে দাম দেবে (প্রতি kWh টাকা)';

  @override
  String get paramNetMetering => 'বাড়তি বিদ্যুৎ গ্রিডে বিক্রি (নেট মিটারিং)';

  @override
  String get paramPsh => 'দিনে রোদের ঘণ্টা';

  @override
  String get paramPshHint =>
      'খালি রাখলে: আপনার ছাদের জন্য NASA-র স্যাটেলাইট রোদের তথ্য ব্যবহার হবে।';

  @override
  String paramDefault(String value) {
    return 'সাধারণ মান $value';
  }

  @override
  String get solarEstimate => 'অনুমান করুন';

  @override
  String get solarResultTitle => 'সোলার অনুমান';

  @override
  String get solarRoofArea => 'ছাদের আয়তন';

  @override
  String get solarUsableArea => 'ব্যবহারযোগ্য আয়তন';

  @override
  String get solarSize => 'সিস্টেমের আকার';

  @override
  String get solarAnnualGen => 'বার্ষিক উৎপাদন';

  @override
  String get solarOffset => 'চাহিদার যে অংশ পূরণ হবে';

  @override
  String get solarCo2 => 'বছরে এড়ানো CO2';

  @override
  String get solarPsh => 'পিক সান আওয়ার (গড়)';

  @override
  String get solarSourceNasa => 'NASA POWER';

  @override
  String get solarSourceManual => 'হাতে দেওয়া';

  @override
  String get solarFinancials => 'টাকার হিসাব';

  @override
  String get solarCapex => 'বসানোর খরচ';

  @override
  String get solarYear1Savings => 'প্রথম বছরে সাশ্রয়';

  @override
  String get solarYear1Om => 'প্রথম বছরে রক্ষণাবেক্ষণ';

  @override
  String get solarPayback => 'খরচ উঠে আসবে';

  @override
  String get solarNoPayback => 'বিনিয়োগ ফেরত আসে না';

  @override
  String get solarNoFinancials =>
      'সাশ্রয় ও খরচ উঠে আসার সময় দেখতে প্রতি kW-এর দাম লিখুন।';

  @override
  String get solarCashflow => 'ক্রমপুঞ্জিত নগদ প্রবাহ (মিলিয়ন টাকা)';

  @override
  String get solarSavePlan => 'পরিকল্পনা সংরক্ষণ';

  @override
  String get solarPlanName => 'পরিকল্পনার নাম';

  @override
  String get solarPlanSaved => 'পরিকল্পনা সংরক্ষিত হয়েছে';

  @override
  String get solarNotes => 'নোট';

  @override
  String get solarDisclaimer =>
      'শুধু অনুমান। আসল সাশ্রয় নির্ভর করে বসানো সিস্টেম, তার খরচ, ট্যারিফ, ছায়া এবং কারখানা কতটা সোলার বিদ্যুৎ ব্যবহার করে তার ওপর। ছাদের শক্তি ও বৈদ্যুতিক নকশা পেশাদার দিয়ে যাচাই করাতে হবে।';

  @override
  String valueYears(String value) {
    return '$value বছর';
  }

  @override
  String valueKwp(String value) {
    return '$value kWp';
  }

  @override
  String valueKwhYear(String value) {
    return '$value kWh/বছর';
  }

  @override
  String valueM2(String value) {
    return '$value m²';
  }

  @override
  String valueTk(String value) {
    return '$value টাকা';
  }

  @override
  String valuePercent(String value) {
    return '$value%';
  }

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get languageSystem => 'ডিভাইসের ভাষা';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get settingsKeepImages => 'বিলের ছবি এই ফোনে রাখুন';

  @override
  String get settingsKeepImagesHint =>
      'বন্ধ থাকলে: মান পড়ার পর ছবি মুছে ফেলা হয়।';

  @override
  String get settingsFactory => 'কারখানার প্রোফাইল';

  @override
  String get settingsDataHandling => 'আপনার ডেটা কীভাবে ব্যবহৃত হয়';

  @override
  String get settingsLimitations => 'জানা সীমাবদ্ধতা';

  @override
  String get settingsLoadDemo => 'ডেমো তথ্য লোড করুন (কৃত্রিম)';

  @override
  String get settingsLoadDemoHint =>
      '২৪ মাসের বানানো বিল ও উৎপাদনের তথ্য যোগ করে, যাতে ২টি ইচ্ছাকৃত অস্বাভাবিকতা আছে।';

  @override
  String get settingsRemoveDemo => 'ডেমো তথ্য সরান';

  @override
  String get demoLoaded => 'কৃত্রিম ডেমো তথ্য লোড হয়েছে';

  @override
  String get demoRemoved => 'ডেমো তথ্য সরানো হয়েছে';

  @override
  String get settingsDeleteAll => 'আমার সব তথ্য মুছুন';

  @override
  String get deleteAllConfirmTitle => 'সব তথ্য মুছবেন?';

  @override
  String get deleteAllConfirmBody =>
      'এটি এই ফোন থেকে কারখানার প্রোফাইল, বিল, উৎপাদন, সোলার পরিকল্পনা, সংরক্ষিত রিপোর্ট ও রাখা ছবি স্থায়ীভাবে মুছে দেবে। এটি ফেরানো যাবে না।';

  @override
  String get deleteAllDone => 'সব তথ্য মুছে ফেলা হয়েছে';

  @override
  String get settingsServer => 'সার্ভার';

  @override
  String get serverStatusOk => 'সংযুক্ত';

  @override
  String get serverStatusError => 'পৌঁছানো যাচ্ছে না';

  @override
  String get serverExtractionOff =>
      'সার্ভারে বিল পড়ার সুবিধা কনফিগার করা নেই; হাতে লিখুন।';

  @override
  String get settingsExport => 'রপ্তানি';

  @override
  String get dataHandlingTitle => 'আপনার ডেটা কীভাবে ব্যবহৃত হয়';

  @override
  String get dataHandlingPhoneTitle => 'এই ফোনে সংরক্ষিত';

  @override
  String get dataHandlingPhoneBody =>
      'কারখানার প্রোফাইল, নিশ্চিতকৃত বিল, উৎপাদন, সোলার পরিকল্পনা ও সর্বশেষ হিসাব করা রিপোর্ট। বিলের ছবি শুধু \"বিলের ছবি রাখুন\" চালু করলে। সেটিংস থেকে যেকোনো সময় সব মুছতে পারেন।';

  @override
  String get dataHandlingServerTitle => 'আমাদের সার্ভারে পাঠানো হয়';

  @override
  String get dataHandlingServerBody =>
      'কাটা বিলের ছবি (পড়ার জন্য), এবং প্রতিটি হিসাবের জন্য প্রয়োজনীয় সংখ্যা: মাসিক পরিমাণ, টাকার পরিমাণ, উৎপাদন, ছাদের রেখা। সার্ভার কিছুই রাখে না: কোনো ডেটাবেস নেই, ছবি সংরক্ষণ হয় না, অনুরোধের বিষয়বস্তু লগ হয় না।';

  @override
  String get dataHandlingGoogleTitle => 'Google-এ পাঠানো হয়';

  @override
  String get dataHandlingGoogleBody =>
      'মান পড়ার জন্য কাটা বিলের ছবি Google-এর Gemini API-তে যায়, Google-এর Gemini API শর্ত অনুযায়ী। Google-এর বিনামূল্যের (অপরিশোধিত) স্তরে Google বিষয়বস্তু তার পণ্য উন্নয়নে ব্যবহার করতে পারে এবং মানব পর্যালোচকরা তা পড়তে পারেন; পরিশোধিত (বিলিং-সক্রিয়) প্রকল্পে এভাবে ব্যবহার করে না। আপলোডের আগে ব্যক্তিগত তথ্য কেটে দিন। অ্যাপ কখনো Gemini-এর কাছে নাম, ঠিকানা, কনজিউমার বা মিটার নম্বর চায় না।';

  @override
  String get dataHandlingNasaTitle => 'NASA POWER-এ পাঠানো হয়';

  @override
  String get dataHandlingNasaBody =>
      'সোলার অনুমানের জন্য আমাদের সার্ভার ছাদের আনুমানিক (রাউন্ড করা) অবস্থানের সূর্যালোকের তথ্য NASA POWER থেকে চায়। অন্য কোনো তথ্য পাঠানো হয় না।';

  @override
  String get limitationsTitle => 'জানা সীমাবদ্ধতা';

  @override
  String get limitationsBody =>
      '• শুধু ইউটিলিটি বিল থেকে স্কোপ ১ ও ২। স্কোপ ৩ নেই; হাতে না লিখলে কয়লা, বায়োমাস বা অন্য জ্বালানি নেই।\n• ক্রেতার চাহিদার সাথে পদ্ধতি ও ফরম্যাট মিলিয়ে না নেওয়া পর্যন্ত নির্গমন রিপোর্টটি খসড়া।\n• বিল পড়ার নির্ভুলতা মাত্র কয়েকটি নমুনা বিলে মাপা হয়েছে। সবসময় মান যাচাই করুন।\n• শুধু ইংরেজি অক্ষরে ছাপানো নাম নিজে থেকে ঢাকা হয়। হাতে লেখা বা বাংলা নাম নিজে ঢেকে দিন।\n• অস্বাভাবিক ব্যবহারের যাচাই উৎপাদনের তুলনায় পরিসংখ্যানগত ব্যতিক্রম দেখায়; কারণ বলতে পারে না এবং অপচয় প্রমাণ করে না।\n• মাপা সাশ্রয় কাজের আগে ও পরে পুরো কারখানার তুলনা; আবহাওয়া, পণ্যের ধরন বা অন্য পরিবর্তনেরও ভূমিকা থাকতে পারে।\n• সোলারের ফল শুধু অনুমান।\n• নির্গমন গুণক প্রকাশিত সরকারি উৎস থেকে নেওয়া (রিপোর্টে উৎস ও বছরসহ দেখানো)। নতুন সংস্করণ এলে হালনাগাদ করুন এবং ক্রেতার নিয়মের সাথে মিলিয়ে নিন।\n• অ্যাপ টোকেন দুর্বল সুরক্ষা, শুধু ডেমোর জন্য যথেষ্ট।';

  @override
  String get demoNeedsEmpty =>
      'অ্যাপে বাস্তব বিল বা উৎপাদনের তথ্য না থাকলেই কেবল ডেমো তথ্য লোড করা যায়। আগে আপনার তথ্য রপ্তানি বা মুছে ফেলুন।';

  @override
  String get carbonStale =>
      'এই রিপোর্ট হিসাবের পর আপনার তথ্য বদলেছে। রিপোর্ট হালনাগাদ করুন।';

  @override
  String get serverSettingsTitle => 'সার্ভার সংযোগ';

  @override
  String get serverUrlLabel => 'সার্ভারের ঠিকানা';

  @override
  String get serverUrlHint =>
      'যেমন 192.168.1.20:8000 বা https://api.example.com';

  @override
  String get serverTokenLabel => 'অ্যাপ টোকেন';

  @override
  String get serverTest => 'সংযোগ পরীক্ষা করুন';

  @override
  String get serverReset => 'ডিফল্ট ব্যবহার করুন';

  @override
  String get serverInvalidUrl => 'সঠিক ঠিকানা লিখুন, যেমন 192.168.1.20:8000';

  @override
  String get serverSaved => 'সার্ভার সেটিংস সংরক্ষিত হয়েছে';

  @override
  String get serverTestOk => 'সার্ভারে সংযুক্ত হয়েছে।';

  @override
  String get serverHelp =>
      'ফোনে পরীক্ষা করছেন? কম্পিউটারে start_backend.ps1 চালান, ফোন ও কম্পিউটার একই Wi-Fi-তে যুক্ত করুন, তারপর স্ক্রিপ্টে দেখানো ঠিকানা ও টোকেন এখানে লিখুন (যেমন 192.168.1.20:8000)।';

  @override
  String serverCurrent(String url) {
    return 'এখন ব্যবহৃত: $url';
  }

  @override
  String get languageChoose => 'ভাষা / Language';

  @override
  String get pickMonth => 'মাস নির্বাচন করুন';

  @override
  String get previousYear => 'আগের বছর';

  @override
  String get nextYear => 'পরের বছর';

  @override
  String get homeGettingStarted => 'শুরু করার ধাপ';

  @override
  String get stepAddData => 'একটি বিল যোগ করুন বা পুরোনো মাস ইমপোর্ট করুন';

  @override
  String get stepProduction => 'মাসিক উৎপাদন লিখুন';

  @override
  String get stepReport => 'আপনার কার্বন রিপোর্ট তৈরি করুন';

  @override
  String get stepWaste => 'অস্বাভাবিক বিদ্যুৎ ব্যবহার যাচাই করুন';

  @override
  String get homeStatMonths => 'মাস';

  @override
  String get homeStatLatest => 'সর্বশেষ মাস';

  @override
  String get homeTryDemo =>
      'শুধু দেখছেন? সব সুবিধা দেখতে কৃত্রিম ডেমো তথ্য লোড করুন।';

  @override
  String get homeLoadDemo => 'ডেমো তথ্য লোড করুন';

  @override
  String get filterAll => 'সব';

  @override
  String get reviewMainSection => 'প্রধান মান';

  @override
  String get reviewMoreDetails => 'আরও তথ্য (ঐচ্ছিক)';

  @override
  String get reviewImageHint => 'দুই আঙুল দিয়ে বিল বড় করে দেখুন';

  @override
  String get addBillScanTitle => 'বিল স্ক্যান করুন';

  @override
  String get addBillScanHint =>
      'ছবি তুলুন বা বেছে নিন। সংরক্ষণের আগে ব্যক্তিগত তথ্য ঢেকে দেবেন এবং প্রতিটি মান যাচাই করবেন।';

  @override
  String get solarMyLocation => 'কারখানার অবস্থানে যান';

  @override
  String get errInvalidPolygon =>
      'ছাদের রেখা সঠিক নয়। রেখাগুলো যেন একে অপরকে না কাটে।';

  @override
  String get errPolygonTooSmall =>
      'ছাদের রেখা খুব ছোট। জুম করে ছাদের কোণগুলোতে ট্যাপ করুন।';

  @override
  String get errPolygonTooLarge =>
      'ছাদের রেখা খুব বড়। শুধু কারখানার ছাদ আঁকুন।';

  @override
  String get errUnitMismatch =>
      'একটি সংরক্ষিত এন্ট্রির একক তার ধরনের সাথে মেলে না। বিল তালিকায় ঠিক করুন।';

  @override
  String get errIrradiance =>
      'সূর্যালোকের তথ্য পাওয়া যায়নি। হাতে পিক সান আওয়ার লিখুন বা আবার চেষ্টা করুন।';

  @override
  String get errDailyCap =>
      'আজকের বিল পড়ার সীমা শেষ। আগামীকাল চেষ্টা করুন বা হাতে লিখুন।';

  @override
  String get errExtractionFailed =>
      'বিলটি পড়া যায়নি। আরও পরিষ্কার ছবি দিন বা হাতে লিখুন।';

  @override
  String get errFileTooLarge => 'ছবিটি খুব বড়।';

  @override
  String get errUnsupportedFile => 'JPG, PNG বা PDF ফাইল ব্যবহার করুন।';

  @override
  String get errInvalidToken =>
      'সার্ভার অ্যাপ টোকেন গ্রহণ করেনি। সেটিংসে সার্ভার সংযোগ পরীক্ষা করুন।';

  @override
  String get errExtractionUnavailable =>
      'সার্ভারে এখনো বিল পড়ার সুবিধা চালু হয়নি। হাতে বিল লিখুন।';

  @override
  String swConsumptionPartial(String count) {
    return 'আপনার বিদ্যুতের তথ্য ১২ মাসের মধ্যে $count মাসের; বাকি মাসে গড় মাস ধরা হয়েছে।';
  }

  @override
  String swExcessNotCounted(String kwh) {
    return 'প্রায় $kwh kWh/বছর ঐ মাসগুলোর ব্যবহারের চেয়ে বেশি, তাই হিসাবে ধরা হয়নি (নেট মিটারিং নেই)।';
  }

  @override
  String get swNoConsumption =>
      'এখনো বিদ্যুৎ বিল নেই, তাই চাহিদার কত অংশ পূরণ হবে ও সাশ্রয় অনুমান করা যায়নি।';

  @override
  String get swGridFactorNotSet =>
      'সার্ভারে গ্রিড নির্গমন ফ্যাক্টর নির্ধারিত নেই, তাই এড়ানো CO2 হিসাব করা হয়নি।';

  @override
  String get swCo2NeedsConsumption =>
      'এড়ানো CO2 হিসাবের জন্য আপনার বিদ্যুতের তথ্য (বা নেট মিটারিং) প্রয়োজন।';

  @override
  String get swGridPlaceholder =>
      'এড়ানো CO2 হিসাবে অযাচাইকৃত গ্রিড নির্গমন ফ্যাক্টর ব্যবহৃত হয়েছে।';

  @override
  String get swPriceMissing =>
      'সাশ্রয় হিসাবের জন্য বিদ্যুতের দাম প্রয়োজন: দাম লিখুন বা টাকার পরিমাণসহ বিল যোগ করুন।';

  @override
  String get swFinancialsNeedConsumption =>
      'নেট মিটারিং না থাকলে সাশ্রয় হিসাবের জন্য আপনার বিদ্যুতের তথ্য প্রয়োজন।';

  @override
  String get swOmNotIncluded => 'রক্ষণাবেক্ষণ (O&M) খরচ ধরা হয়নি।';

  @override
  String get swExportPriceMissing =>
      'নেট মিটারিং চালু কিন্তু রপ্তানি মূল্য নেই; রপ্তানি করা বিদ্যুতের মূল্য শূন্য ধরা হয়েছে।';

  @override
  String get swFinancialAssumptions =>
      'বিদ্যুতের দাম স্থির এবং কোনো ঋণ খরচ নেই ধরে নেওয়া হয়েছে।';

  @override
  String get swNoPayback =>
      'বার্ষিক সাশ্রয় রক্ষণাবেক্ষণ খরচ পূরণ করে না, তাই পেব্যাক নেই।';

  @override
  String get introSkip => 'এড়িয়ে যান';

  @override
  String get introNext => 'পরবর্তী';

  @override
  String get introGetStarted => 'শুরু করুন';

  @override
  String get intro1Title => 'বিলের ছবি তুলুন, আমরা পড়ে নেব';

  @override
  String get intro1Body =>
      'বিদ্যুৎ, গ্যাস বা ডিজেল বিলের ছবি তুলুন। AI সংখ্যাগুলো পড়ে নেয়, আর সংরক্ষণের আগে আপনি সেগুলো যাচাই করেন।';

  @override
  String get intro2Title => 'এক ট্যাপে কার্বন রিপোর্ট';

  @override
  String get intro2Body =>
      'ক্রেতারা যে স্কোপ ১ + ২ কার্বন রিপোর্ট চান, তা PDF বা স্প্রেডশিট হিসেবে শেয়ার করুন।';

  @override
  String get intro3Title => 'অপচয় কমান, সোলারে যান';

  @override
  String get intro3Body =>
      'অস্বাভাবিক বেশি বিদ্যুৎ ব্যবহারের মাস খুঁজে পান এবং ছাদে সোলার কত সাশ্রয় করতে পারে তা অনুমান করুন।';

  @override
  String get introPrivacyNote => 'আপনার তথ্য এই ফোনেই থাকে।';

  @override
  String get onboardingFormSubtitle =>
      'রিপোর্টের জন্য কিছু তথ্য। পরে পরিবর্তন করতে পারবেন।';

  @override
  String get factoryCoordsHint =>
      'ঐচ্ছিক। সোলার মানচিত্রে আপনার কারখানা দেখাতে ব্যবহৃত হয়।';

  @override
  String get homeGreetingMorning => 'শুভ সকাল';

  @override
  String get homeGreetingAfternoon => 'শুভ অপরাহ্ন';

  @override
  String get homeGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get homeFootprint => 'কার্বন ফুটপ্রিন্ট';

  @override
  String get homeHeroEmpty => 'চলুন আপনার কারখানার জ্বালানি ও কার্বন মাপি।';

  @override
  String get homeScanTitle => 'বিল স্ক্যান করুন';

  @override
  String get homeScanSubtitle =>
      'বিদ্যুৎ, গ্যাস বা ডিজেল বিলের ছবি তুলুন। সংখ্যাগুলো আমরা পড়ে দেব।';

  @override
  String get homeExplore => 'আপনি কী করতে চান?';

  @override
  String get tileBillsSub => 'সংরক্ষিত বিল দেখুন ও সম্পাদনা করুন';

  @override
  String get tileImportSub => 'স্প্রেডশিট থেকে পুরোনো মাস যোগ করুন';

  @override
  String get tileProductionSub => 'তীব্রতার জন্য মাসিক উৎপাদন';

  @override
  String get tileCarbonSub => 'খসড়া স্কোপ ১ + ২ রিপোর্ট ও PDF';

  @override
  String get tileWasteSub => 'উৎপাদনের তুলনায় যে মাসে বেশি বিদ্যুৎ লেগেছে';

  @override
  String get tileSolarSub => 'ছাদে সোলারের অনুমান';

  @override
  String get connOfflineTitle => 'সার্ভারের সাথে সংযোগ নেই';

  @override
  String get connOfflineBody =>
      'বিল পড়া, রিপোর্ট ও সোলারের জন্য সার্ভার প্রয়োজন। আপনার সংরক্ষিত তথ্য এই ফোনে নিরাপদ আছে।';

  @override
  String get connOnline => 'সার্ভার সংযুক্ত';

  @override
  String get connChecking => 'সংযোগ পরীক্ষা হচ্ছে…';

  @override
  String get connReadingOn => 'বিল পড়া প্রস্তুত';

  @override
  String get uploadStepSend => 'ছবি পাঠানো হচ্ছে';

  @override
  String get uploadStepRead => 'AI বিলটি পড়ছে';

  @override
  String get uploadStepReview => 'আপনি প্রতিটি মান যাচাই করবেন';

  @override
  String get addBillTipsTitle => 'ভালো ছবির জন্য পরামর্শ';

  @override
  String get addBillTip1 => 'বিলটি সমান জায়গায় ভালো আলোতে রাখুন';

  @override
  String get addBillTip2 => 'পুরো বিলটি ছবির মধ্যে রাখুন';

  @override
  String get addBillTip3 => 'নাম ও ঠিকানা নিজে থেকেই ঢেকে যায়';

  @override
  String get addBillOr => 'অথবা';

  @override
  String get billsSubtitle => 'আপনার সব জ্বালানি বিল এক জায়গায়';

  @override
  String get reportsSubtitle =>
      'কার্বন ফুটপ্রিন্ট, অস্বাভাবিক ব্যবহার ও আপনার সাশ্রয়';

  @override
  String get solarSubtitle => 'আপনার কারখানার ছাদে সোলারের অনুমান';

  @override
  String get settingsSubtitle => 'ভাষা, সার্ভার, গোপনীয়তা ও আপনার তথ্য';

  @override
  String get solarHowTitle => 'কীভাবে কাজ করে';

  @override
  String get solarHow1 => 'মানচিত্রে ছাদ আঁকুন';

  @override
  String get solarHow2 => 'অনুমানগুলো দেখে নিন';

  @override
  String get solarHow3 => 'আকার, উৎপাদন ও পেব্যাক দেখুন';

  @override
  String get wasteAllGoodTitle => 'সব ঠিক আছে';

  @override
  String get wasteAttentionTitle => 'অস্বাভাবিক মাস পাওয়া গেছে';

  @override
  String get carbonScopeSplit => 'স্কোপ ১ (জ্বালানি) বনাম স্কোপ ২ (বিদ্যুৎ)';

  @override
  String get reviewAiRead => 'AI দিয়ে পড়া হয়েছে';

  @override
  String get reviewManualBadge => 'হাতে লেখা';

  @override
  String get redactTitle => 'ব্যক্তিগত তথ্য ঢেকে দিন';

  @override
  String get redactHint =>
      'ছবিটি দেখে নিন। আর কিছু ঢাকতে চাইলে (যেমন গ্রাহক বা মিটার নম্বর) তার ওপর আঙুল টেনে দিন। কালো বক্স সরাতে বক্সে চাপুন।';

  @override
  String get redactKeepVisible => 'ইউনিট, টাকার পরিমাণ ও তারিখ দৃশ্যমান রাখুন।';

  @override
  String get redactNothing =>
      'ছবিতে কোনো ব্যক্তিগত তথ্য নেই? সরাসরি এগিয়ে যান।';

  @override
  String get redactSend => 'বিলটি পড়ুন';

  @override
  String get redactPreparing => 'তথ্য ঢাকা হচ্ছে…';

  @override
  String redactAreas(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি অংশ ঢাকা হয়েছে',
      zero: 'কোনো অংশ ঢাকা হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get productionUnitHelp =>
      'শুধু একটি চাপুন। প্রতি মাসে কত তৈরি করলেন, তা পরে \'উৎপাদন\' পাতায় লিখবেন।';

  @override
  String get unitPieces => 'পিস';

  @override
  String get unitDozens => 'ডজন';

  @override
  String get unitKg => 'কেজি';

  @override
  String get unitMeters => 'মিটার';

  @override
  String get unitOther => 'অন্য';

  @override
  String get unitOtherHint => 'আপনার একক লিখুন, যেমন: সেট';

  @override
  String get cropYes => 'কিনারা কাটুন';

  @override
  String get cropSkip => 'না, এগিয়ে যান';

  @override
  String get redactScanning => 'নাম ও ঠিকানা খোঁজা হচ্ছে…';

  @override
  String redactAutoFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✓ $countটি নাম/ঠিকানার অংশ নিজে থেকেই ঢাকা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get redactAutoNone =>
      'ছাপানো কোনো নাম পাওয়া যায়নি। কোনো নাম দেখলে তার ওপর আঙুল টেনে দিন।';

  @override
  String co2Kg(String kg) {
    return '= $kg কেজি CO₂ গ্যাস';
  }

  @override
  String co2Trees(String trees) {
    return 'এটা শুষে নিতে প্রায় $treesটি গাছের পুরো এক বছর লাগবে।';
  }

  @override
  String get co2WhatTitle => 'এই সংখ্যার মানে কী?';

  @override
  String get co2WhatBody =>
      'কারখানা বিদ্যুৎ, গ্যাস বা ডিজেল ব্যবহার করলে বাতাসে কার্বন ডাই-অক্সাইড (CO₂) গ্যাস যায়। এই গ্যাস পৃথিবীকে গরম করে। সংখ্যাটি দেখায় আপনার কারখানা কতটা করেছে।\n\n• টন: ১ টন = ১,০০০ কেজি।\n• CO₂e মানে \"CO₂-এর সমান\": গরম করে এমন অন্য গ্যাসগুলোকেও সমপরিমাণ CO₂ ধরে গোনা হয়।\n• স্কোপ ২ = গ্রিডের যে বিদ্যুৎ কেনেন তা থেকে। বিদ্যুৎকেন্দ্র গ্যাস ও তেল পুড়িয়ে তা তৈরি করে।\n• স্কোপ ১ = কারখানা নিজে যে জ্বালানি পোড়ায়: ডিজেল জেনারেটর, গ্যাস বয়লার।\n\nহিসাব: বিলের ইউনিট × নির্গমন গুণক। উদাহরণ: ১,০০০ kWh × প্রতি kWh-এ ০.৬২ কেজি = ৬২০ কেজি = ০.৬২ টন CO₂e।\n\nবিদেশি ক্রেতারা এই সংখ্যা চান। যত কম, তত ভালো: বিদ্যুৎ বাঁচালে বা সোলার ব্যবহার করলে এটা কমে।';

  @override
  String get co2Explain => 'এর মানে কী?';

  @override
  String get tutorialTitle => 'কীভাবে ব্যবহার করবেন';

  @override
  String get tutorialListen => 'শুনুন';

  @override
  String get tutorialStop => 'থামুন';

  @override
  String get tutorialNoVoice =>
      'এই ফোন এখনো এই ভাষায় বলতে পারে না। সেটিংস › টেক্সট-টু-স্পিচ থেকে কণ্ঠ ইনস্টল করুন।';

  @override
  String tutorialStep(String n, String total) {
    return 'ধাপ $n / $total';
  }

  @override
  String get tut1Title => 'বিলের ছবি তুলুন';

  @override
  String get tut1Body =>
      'বড় + বোতামে চাপুন, তারপর ক্যামেরা। বিদ্যুৎ, গ্যাস বা ডিজেলের বিল নিন।';

  @override
  String get tut2Title => 'আপনার নাম লুকানো থাকে';

  @override
  String get tut2Body =>
      'কালো বক্স নিজে থেকেই নাম ও ঠিকানা ঢেকে দেয়। তারপর \"বিলটি পড়ুন\" চাপুন।';

  @override
  String get tut3Title => 'সংখ্যাগুলো মিলিয়ে নিন';

  @override
  String get tut3Body =>
      'অ্যাপ ইউনিট আর টাকা পড়ে নেয়। বিলের সাথে মিললে \'সংরক্ষণ\' চাপুন।';

  @override
  String get tut4Title => 'কত তৈরি করলেন লিখুন';

  @override
  String get tut4Body =>
      'প্রতি মাসে কারখানা কত পিস তৈরি করল, তা \'উৎপাদন\' পাতায় লিখুন।';

  @override
  String get tut5Title => 'কার্বন রিপোর্ট নিন';

  @override
  String get tut5Body =>
      'আপনার কারখানা কতটা দূষণ করে দেখুন, আর PDF ক্রেতাকে পাঠান।';

  @override
  String get tut6Title => 'টাকা বাঁচান';

  @override
  String get tut6Body =>
      'লাল সতর্কতা মানে ওই মাসে বিদ্যুৎ অপচয় হয়েছে। সূর্যের পাতা দেখায় সোলার প্যানেল কত টাকা বাঁচাতে পারে।';

  @override
  String get homeHowTo => 'কীভাবে ব্যবহার করবেন';

  @override
  String wastePerUnit(String actual, String expected) {
    return 'প্রতি ইউনিট উৎপাদনে kWh: $actual (প্রত্যাশিত $expected)';
  }

  @override
  String wasteBaseline(String value) {
    return 'সাধারণ মাসে: প্রতি ইউনিট উৎপাদনে $value kWh';
  }

  @override
  String get wasteChecksTitle => 'কী কী দেখবেন';

  @override
  String get wasteChecksIntro =>
      'ক্রমানুসারে দেখুন। সমাধানটি কাজের পরিকল্পনায় যোগ করুন; পরের বিল থেকে অ্যাপ সাশ্রয় মেপে দেবে।';

  @override
  String get paramRoofStructure => 'ছাদ কি প্যানেলের ভার নিতে পারবে?';

  @override
  String get roofUnknown => 'যাচাই হয়নি';

  @override
  String get roofOk => 'প্রকৌশলী: হ্যাঁ';

  @override
  String get roofNeedsWork => 'কাজ লাগবে';

  @override
  String get swShadingNotAssessed =>
      'ছায়ার তথ্য দেওয়া হয়নি, তাই কোনো ছায়া ধরা হয়নি। ট্যাংক, গাছ বা ভবনের ছায়ায় উৎপাদন কমে।';

  @override
  String get swStructureUnknown =>
      'ছাদের শক্তি এখনো যাচাই হয়নি। ছাদ প্যানেলের ভার নিতে পারবে কি না, প্রকৌশলীকে নিশ্চিত করতে হবে।';

  @override
  String get swStructureNeedsWork =>
      'আগে ছাদে কাঠামোগত কাজ লাগবে; সেই খরচ বিনিয়োগে যোগ করুন।';

  @override
  String get swTariffAverage =>
      'সাশ্রয় হিসাবে বিলের গড় দাম (ডিমান্ড চার্জ ও ভ্যাটসহ) ধরা হয়েছে। সোলার মূলত এনার্জি চার্জ কমায়, তাই আসল সাশ্রয় কম হতে পারে। আরও কাছাকাছি হিসাবের জন্য এনার্জি চার্জের হার লিখুন।';

  @override
  String get tabCarbon => 'কার্বন';

  @override
  String get tabUnusual => 'অস্বাভাবিক';

  @override
  String get tabImpact => 'সাশ্রয়';

  @override
  String get impactTitle => 'কাজ ও সাশ্রয়';

  @override
  String get tileImpactSub => 'আপনার কাজের পরিকল্পনা ও মাপা সাশ্রয়';

  @override
  String get impactIntro =>
      'নিচ থেকে একটি কাজ বেছে নিন, করুন, তারপর \'হয়ে গেছে\' চাপুন। অ্যাপ আপনার নিজের বিল থেকে আগে ও পরে প্রতি ইউনিট উৎপাদনে বিদ্যুৎ মিলিয়ে দেখায়, তাই আন্দাজ নয়, আসল সাশ্রয় দেখবেন।';

  @override
  String get impactNothingDone =>
      'কাজ শেষ হলে \"হয়ে গেছে\" চাপুন। পরের মাসগুলোর বিল থেকে সাশ্রয় মাপা হবে।';

  @override
  String get impactTooEarly => 'ফল দেখতে কাজের পরের মাসগুলোর বিল যোগ করুন।';

  @override
  String get impactNoBaseline =>
      'তুলনার জন্য কাজের আগের অন্তত ৩ মাসের বিল লাগবে।';

  @override
  String get impactNeedProduction =>
      'ন্যায্যভাবে সাশ্রয় মাপতে মাসিক উৎপাদন যোগ করুন (বেশি উৎপাদনে বেশি বিদ্যুৎ লাগতেই পারে)।';

  @override
  String impactSince(String month) {
    return '$month থেকে মাপা সাশ্রয়';
  }

  @override
  String impactTkSaved(String amount) {
    return '$amount টাকা সাশ্রয়';
  }

  @override
  String impactKwhSaved(String kwh) {
    return '$kwh kWh সাশ্রয়';
  }

  @override
  String impactKwhLine(String kwh) {
    return '$kwh kWh কম বিদ্যুৎ';
  }

  @override
  String impactIntensityLine(String pct) {
    return 'প্রতি ইউনিট উৎপাদনে বিদ্যুৎ: আগের তুলনায় $pct%';
  }

  @override
  String impactMeasuredMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস ধরে মাপা',
    );
    return '$_temp0';
  }

  @override
  String impactEarly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রাথমিক ফল: এখন পর্যন্ত $count মাস',
    );
    return '$_temp0';
  }

  @override
  String get impactCo2NeedsReport =>
      'কত CO₂ কমল দেখতে কার্বন রিপোর্ট হালনাগাদ করুন।';

  @override
  String get impactCaveat =>
      'উৎপাদন অনুযায়ী সমন্বয় করা, আপনার নিজের বিল থেকে। আবহাওয়া, পণ্যের ধরন বা অন্য পরিবর্তনেরও ভূমিকা থাকতে পারে।';

  @override
  String get impactChartTitle => 'প্রতি মাসে, প্রতি ইউনিট উৎপাদনে kWh';

  @override
  String get impactBefore => 'আগে';

  @override
  String get impactAfter => 'পরে';

  @override
  String get impactBaseline => 'আগের গড়';

  @override
  String get impactMethod =>
      'ভিত্তি = প্রথম কাজের আগের সর্বোচ্চ ১২ মাসে প্রতি ইউনিটে kWh। প্রতি মাসের সাশ্রয় = ভিত্তি × উৎপাদিত ইউনিট − আসল kWh। কাজের মাসটি বাদ দেওয়া হয়।';

  @override
  String get impactCommunityTitle => 'কারখানার বাইরেও কেন গুরুত্বপূর্ণ';

  @override
  String get impactCommunityBody =>
      'কম বিদ্যুৎ মানে বিদ্যুৎকেন্দ্রে কম গ্যাস ও তেল পোড়ে: কারখানার আশেপাশের পরিবারের জন্য পরিষ্কার বাতাস, আর বাড়ি ও হাসপাতালের জন্য গ্রিডে বেশি বিদ্যুৎ। বাঁচানো টাকা মজুরি ও নিরাপদ কর্মস্থলে খরচ করা যায়।';

  @override
  String get actionPlanTitle => 'আমার কাজের পরিকল্পনা';

  @override
  String get actionPlanEmpty =>
      'এখনো কোনো কাজ নেই। নিচের পরামর্শ থেকে একটি যোগ করুন।';

  @override
  String get actionSuggestions => 'প্রস্তাবিত কাজ';

  @override
  String get actionAddToPlan => 'পরিকল্পনায় যোগ করুন';

  @override
  String get actionAddOwn => 'নিজের কাজ';

  @override
  String get actionAdded => 'কাজের পরিকল্পনায় যোগ হয়েছে';

  @override
  String get actionAlreadyInPlan => 'আগেই পরিকল্পনায় আছে';

  @override
  String get actionPlanned => 'পরিকল্পিত';

  @override
  String actionDoneIn(String month) {
    return '$month-এ সম্পন্ন';
  }

  @override
  String get actionMarkDone => 'হয়ে গেছে';

  @override
  String get actionUndoDone => 'এখনো হয়নি';

  @override
  String get actionRemove => 'সরান';

  @override
  String get actionCostTitle => 'খরচ কত হলো? (ইচ্ছা হলে)';

  @override
  String get actionCostLabel => 'খরচ';

  @override
  String get actionCostHint => 'কাজটি কবে নিজের খরচ তুলে আনে তা দেখাতে।';

  @override
  String get actionSkip => 'বাদ দিন';

  @override
  String get actionCustomTitle => 'আপনার নিজের কাজ';

  @override
  String get actionCustomHint => 'যেমন: ডাইং মেশিনের মোটর মেরামত';

  @override
  String actionResult(String pct, String before, String after) {
    return 'প্রতি ইউনিট উৎপাদনে kWh: $pct% ($before → $after)';
  }

  @override
  String actionPayback(String cost, String months) {
    return 'খরচ $cost টাকা: প্রায় $months মাসে খরচ উঠে আসবে';
  }

  @override
  String get actFixAirLeaks => 'কম্প্রেসড এয়ারের লিক সারান';

  @override
  String get actFixAirLeaksHow =>
      'বিরতির সময় হোস, কাপলিং ও এয়ার গানে হিস শব্দ শুনুন; প্রতিটি লিক চিহ্নিত করে সারান।';

  @override
  String get actSwitchOffIdle => 'অলস মেশিন, বাতি ও ফ্যান বন্ধ রাখুন';

  @override
  String get actSwitchOffIdleHow =>
      'প্রতি ফ্লোরে একজনকে দায়িত্ব দিন: দুপুরের বিরতি, শেষ শিফটের পর ও ছুটির দিনে সব বন্ধ করবেন।';

  @override
  String get actLowerAirPressure => 'কম্প্রেসরের চাপ কমান';

  @override
  String get actLowerAirPressureHow =>
      'মেশিনের যতটুকু দরকার, চাপ ততটুকুতে রাখুন; প্রতিটি বাড়তি বার মানে বাড়তি বিদ্যুৎ।';

  @override
  String get actSteamLeaks => 'স্টিম লিক সারান ও পাইপ মুড়িয়ে দিন';

  @override
  String get actSteamLeaksHow =>
      'লিক ও নষ্ট স্টিম ট্র্যাপ সারান, গরম পাইপ ও ভালভ ইনসুলেট করুন, কনডেনসেট বয়লারে ফেরত দিন।';

  @override
  String get actGeneratorHours => 'শুধু লোডশেডিংয়ে জেনারেটর চালান';

  @override
  String get actGeneratorHoursHow =>
      'বিদ্যুৎ ফিরলেই গ্রিডে ফিরুন; জেনারেটর চালানোর ঘণ্টার খাতা রাখুন।';

  @override
  String get actLedLighting => 'LED বাতি লাগান';

  @override
  String get actLedLightingHow =>
      'টিউবলাইট ও বাল্ব বদলে LED লাগান, যেগুলো সবচেয়ে বেশি সময় জ্বলে সেগুলো দিয়ে শুরু করুন।';

  @override
  String get actServoMotors => 'সেলাই মেশিনে সার্ভো মোটর লাগান';

  @override
  String get actServoMotorsHow =>
      'ক্লাচ মোটর সারাক্ষণ ঘোরে; সার্ভো মোটর শুধু সেলাইয়ের সময় চলে।';

  @override
  String get actPowerFactor => 'পাওয়ার ফ্যাক্টর ঠিক করুন';

  @override
  String get actPowerFactorHow =>
      'বিলে পাওয়ার ফ্যাক্টর জরিমানা থাকলে ইলেকট্রিশিয়ান দিয়ে ক্যাপাসিটর ব্যাংক দেখান বা লাগান।';

  @override
  String get actRooftopSolar => 'ছাদে সোলার বসান';

  @override
  String get actRooftopSolarHow =>
      'অনুমানের জন্য সোলার পাতা দেখুন, তারপর দরপত্র ও ছাদের প্রকৌশলী যাচাই নিন।';

  @override
  String get inspConfirmCause => 'আগে স্বাভাবিক কারণগুলো বাদ দিন';

  @override
  String get inspConfirmCauseHow =>
      'উৎপাদনের হিসাব, ওভারটাইম ও বাড়তি শিফট, নতুন মেশিন এবং গরম আবহাওয়া (ফ্যান, এসি) মিলিয়ে দেখুন।';

  @override
  String get inspCompressedAir => 'কম্প্রেসর ও বাতাসের লিক';

  @override
  String get inspCompressedAirHow =>
      'মেশিন বন্ধ রেখে হোস ও কাপলিংয়ে হিস শব্দ শুনুন। কম্প্রেসর ঠিকমতো লোড-আনলোড হচ্ছে ও দরকারের বেশি চাপে সেট নেই তা দেখুন।';

  @override
  String get inspIdleMachines => 'অলস মেশিন, বাতি ও ফ্যান';

  @override
  String get inspIdleMachinesHow =>
      'দুপুরের বিরতি, শেষ শিফটের পর ও ছুটির দিনে ফ্লোর ঘুরে দেখুন। কেউ ব্যবহার না করলেও কী চালু আছে লিখে রাখুন।';

  @override
  String get inspBoilerSteam => 'বয়লার ও স্টিম';

  @override
  String get inspBoilerSteamHow =>
      'স্টিম লিক, নষ্ট স্টিম ট্র্যাপ ও খোলা গরম পাইপ খুঁজুন; কনডেনসেট বয়লারে ফিরছে কি না দেখুন।';

  @override
  String get inspGenerator => 'জেনারেটর ব্যবহার';

  @override
  String get inspGeneratorHow =>
      'গ্রিডে বিদ্যুৎ থাকা অবস্থায় জেনারেটর চলেছে কি না, আর দেরিতে গ্রিডে ফেরা হয়েছে কি না, জেনারেটরের খাতায় দেখুন।';

  @override
  String factorGases(String gases) {
    return 'অন্তর্ভুক্ত গ্যাস: $gases';
  }

  @override
  String get draftReportNote =>
      'খসড়া নির্গমন রিপোর্ট। এতে প্রতিটি বিল ও তা কীভাবে লেখা হয়েছে, রিপোর্টের সময়কাল, গুণক ও উৎস আছে। আনুষ্ঠানিকভাবে পাঠানোর আগে ক্রেতার সাথে পদ্ধতি ও ফরম্যাট মিলিয়ে নিন।';

  @override
  String actionPaybackUnderMonth(String cost) {
    return 'খরচ $cost টাকা: এক মাসের কম সময়ে উঠে এসেছে';
  }

  @override
  String get solarSearchHint =>
      'এলাকা, রাস্তা বা কারখানার নাম, অথবা স্থানাঙ্ক লিখুন';

  @override
  String get solarSearchNone =>
      'কিছু পাওয়া যায়নি। টঙ্গী বা আশুলিয়ার মতো এলাকার নাম লিখে দেখুন।';

  @override
  String get solarSearchFailed =>
      'খুঁজতে ইন্টারনেট লাগে। সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get solarGps => 'আমার অবস্থান (GPS)';

  @override
  String get solarGpsOff => 'ফোনের সেটিংসে লোকেশন (GPS) চালু করুন।';

  @override
  String get solarGpsDenied => 'লোকেশনের অনুমতি দেওয়া হয়নি।';

  @override
  String get solarGpsFailed =>
      'অবস্থান পাওয়া যায়নি। জানালার কাছে বা বাইরে গিয়ে আবার চেষ্টা করুন।';

  @override
  String get solarZoomedIn => 'জুম করা হয়েছে। এবার কারখানার ছাদে ট্যাপ করুন।';

  @override
  String get solarFindingRoof => 'ছাদের সীমানা খোঁজা হচ্ছে…';

  @override
  String get solarOutlineFound =>
      'ছাদের সীমানা পাওয়া গেছে। আপনার ছাদের সাথে মিলছে কিনা দেখে \'চালিয়ে যান\' চাপুন।';

  @override
  String get solarOutlineNone =>
      'মানচিত্রে এখানে ভবনের সীমানা নেই। ছাদের প্রতিটি কোণে ট্যাপ করুন।';

  @override
  String get solarOutlineOffline =>
      'ভবনের সীমানা আনা যায়নি। ছাদের প্রতিটি কোণে ট্যাপ করুন।';

  @override
  String solarAreaApprox(String area) {
    return 'প্রায় $area m²';
  }

  @override
  String get paramsIntro =>
      'সব ঘর পূরণ করা ঐচ্ছিক। খালি ঘরে সাধারণ মান ধরা হয়, তাই এখনই \'অনুমান করুন\' চাপতে পারেন।';

  @override
  String get paramShadeQuestion => 'ছাদে কি কোনো কিছুর ছায়া পড়ে?';

  @override
  String get paramShadeHint => 'পানির ট্যাংক, গাছ বা পাশের উঁচু ভবন।';

  @override
  String get shadeNone => 'ছায়া নেই';

  @override
  String get shadeSome => 'কিছুটা (১০%)';

  @override
  String get shadeLot => 'অনেক (২৫%)';

  @override
  String get paramRoofHint =>
      'প্যানেলের ওজন আছে। পুরনো বা টিনের ছাদ প্রকৌশলী দিয়ে যাচাই করান।';

  @override
  String get paramCapexHint =>
      'সোলার কোম্পানির কোটেশন থেকে। উদাহরণ: ১০০ kW-এর দাম ৬০ লাখ টাকা হলে লিখুন ৬০,০০০। খালি রাখলেও আকার ও উৎপাদন দেখবেন, শুধু খরচ উঠে আসার সময় দেখবেন না।';

  @override
  String get paramNetMeteringHint =>
      'শুধু যদি আপনার বিতরণ কোম্পানি (DPDC, DESCO, পল্লী বিদ্যুৎ…) অনুমোদন দেয়।';

  @override
  String get paramsAdvanced => 'উন্নত (প্রকৌশলীদের জন্য)';

  @override
  String get paramsAdvancedHint => 'ভালো তথ্য না থাকলে খালি রাখুন।';

  @override
  String get paramUsableRoofHint =>
      'হাঁটার পথ, ট্যাংক ও সিঁড়ি বাদে ছাদের যে অংশে প্যানেল বসবে।';

  @override
  String get paramM2PerKwpHint => 'এক kW প্যানেলের জন্য ফাঁকসহ যত জায়গা লাগে।';

  @override
  String get paramPerformanceRatioHint =>
      'তাপ, ধুলা, তার ও ইনভার্টারের ক্ষতির পর যতটা বিদ্যুৎ থাকে।';

  @override
  String get paramDegradationHint => 'প্রতি বছর প্যানেল একটু কম বিদ্যুৎ দেয়।';

  @override
  String get paramOmHint =>
      'প্রতি বছর পরিষ্কার ও মেরামত খরচ, বসানোর দামের অংশ হিসেবে। সাধারণত ১–২%।';

  @override
  String get invalidPercent => '০ থেকে ১০০-এর মধ্যে একটি সংখ্যা লিখুন';

  @override
  String get solarSearching => 'খোঁজা হচ্ছে…';

  @override
  String get solarGpsFinding => 'আপনার অবস্থান খোঁজা হচ্ছে…';

  @override
  String get shadeUnsure => 'জানি না';

  @override
  String tonnesCo2(String value) {
    return '$value টন CO₂';
  }

  @override
  String get solarPanelsFit => 'আপনার ছাদে যতগুলো সোলার প্যানেল বসবে';

  @override
  String solarPanelsCount(String count) {
    return '$countটি প্যানেল';
  }

  @override
  String solarPanelsEach(String watt, String kw) {
    return 'প্রতিটি $watt W · মোট $kw kW সিস্টেম';
  }

  @override
  String get solarStatUnits => 'ইউনিট/মাস';

  @override
  String get solarStatCovers => 'আপনার ব্যবহারের';

  @override
  String get solarStatPayback => 'খরচ উঠবে';

  @override
  String get solarSummaryTitle => 'সহজ কথায়';

  @override
  String solarSay1(String count, String watt, String kw) {
    return 'আপনার ছাদে $watt W-এর প্রায় $countটি সোলার প্যানেল বসানোর জায়গা আছে। সব মিলিয়ে এটি $kw kW-এর সিস্টেম।';
  }

  @override
  String solarSay2(String units) {
    return 'এগুলো মাসে প্রায় $units ইউনিট (kWh) বিদ্যুৎ তৈরি করবে: রোদের মাসে বেশি, বর্ষায় কম।';
  }

  @override
  String solarSay3(String use, String percent) {
    return 'আপনার কারখানা মাসে প্রায় $use ইউনিট ব্যবহার করে, তাই সোলার এর প্রায় $percent% পূরণ করবে।';
  }

  @override
  String solarSay4(String tk, String capex, String years) {
    return 'বছরে প্রায় $tk টাকা সাশ্রয় হবে। বসানোর খরচ $capex টাকা প্রায় $years বছরে উঠে আসবে।';
  }

  @override
  String get solarSayNoPrice =>
      'সাশ্রয় ও খরচ উঠে আসার সময় দেখতে আগের পাতায় ফিরে প্রতি kW-এর দাম লিখুন।';

  @override
  String get solarSayNoBills =>
      'সোলার আপনার ব্যবহারের কত অংশ পূরণ করবে দেখতে বিদ্যুৎ বিল যোগ করুন।';

  @override
  String get solarChartTitle => 'প্রতি মাসে তৈরি ইউনিট (kWh)';

  @override
  String get solarWorkedTitle => 'কীভাবে হিসাব করা হলো';

  @override
  String get solarWorkedHint => 'ধাপে ধাপে, প্রকৌশলীদের জন্য';

  @override
  String get solarStep1 => 'ম্যাপে আঁকা ছাদের আয়তন';

  @override
  String solarStep2(String percent) {
    return 'প্যানেলের জন্য ব্যবহারযোগ্য: ছাদের $percent% (হাঁটার পথ, ট্যাংক ও সিঁড়ি খালি রেখে)';
  }

  @override
  String solarStep3(String area, String m2) {
    return 'সিস্টেমের আকার: $area m² ÷ প্রতি kW-এ $m2 m²';
  }

  @override
  String solarStep4(String kw, String panelKw) {
    return 'প্যানেল: $kw kW ÷ প্রতি প্যানেলে $panelKw kW';
  }

  @override
  String get solarStep5Nasa =>
      'দিনে পূর্ণ রোদের ঘণ্টা, বছরের গড় (এই ছাদের জন্য NASA স্যাটেলাইট তথ্য)';

  @override
  String get solarStep5Manual => 'দিনে পূর্ণ রোদের ঘণ্টা (আপনার দেওয়া মান)';

  @override
  String solarStep6(String kw, String hours, String pr, String shade) {
    return 'বছরে উৎপাদন: $kw kW × $hours ঘণ্টা × ৩৬৫ দিন × $pr% দক্ষতা$shade';
  }

  @override
  String solarStepShade(String percent) {
    return ' × ছায়ার পরে বাকি $percent%';
  }

  @override
  String solarStep7(String units, String factor) {
    return 'এড়ানো CO₂: গ্রিডের $units kWh বিদ্যুতের বদলে × প্রতি kWh-এ $factor kg';
  }

  @override
  String get solarStepNote =>
      'kWp = পূর্ণ রোদে (১,০০০ W/m²) প্যানেলের ক্ষমতা। এক ঘণ্টা পূর্ণ রোদ = প্রতি m²-এ ১ kWh সূর্যালোক। দক্ষতার মধ্যে তাপ, ধুলা, তার ও ইনভার্টারের ক্ষতি ধরা আছে।';

  @override
  String valueHoursDay(String value) {
    return '$value ঘণ্টা/দিন';
  }

  @override
  String valueWatt(String value) {
    return '$value W';
  }

  @override
  String get paramPanelQuestion => 'প্যানেলের আকার (প্রতি প্যানেলে ওয়াট)';

  @override
  String get paramPanelHint =>
      'প্যানেলের লেবেলে বা কোটেশনে লেখা থাকে। নতুন প্যানেল সাধারণত ৫৪০–৬০০ W। নিশ্চিত না হলে ৫৫০ W রাখুন।';
}
