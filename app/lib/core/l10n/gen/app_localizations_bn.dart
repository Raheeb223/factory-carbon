// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ফ্যাক্টরি এনার্জি ও কার্বন';

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
  String get productionUnitLabel => 'উৎপাদনের একক (যেমন পিস)';

  @override
  String get privacyTitle => 'আপনার ডেটা ও গোপনীয়তা';

  @override
  String get privacyBody =>
      '• কারখানার প্রোফাইল, বিল, উৎপাদন ও রিপোর্ট শুধু এই ফোনেই সংরক্ষিত থাকে।\n• বিল স্ক্যান করলে কাটা (ক্রপ করা) ছবিটি মান পড়ার জন্য আমাদের সার্ভারে এবং Google-এর Gemini API-তে পাঠানো হয়। আগে নাম, ঠিকানা, গ্রাহক/কনজিউমার নম্বর ও মিটার নম্বর কেটে বাদ দিন।\n• আমাদের সার্ভার আপনার ছবি বা তথ্য সংরক্ষণ করে না। Google তার Gemini API শর্ত অনুযায়ী আপলোড পরিচালনা করে: সার্ভার Google-এর বিনামূল্যের সংস্করণ ব্যবহার করলে Google আপলোড তার পণ্য উন্নয়নে ব্যবহার করতে পারে এবং Google-এর কর্মীরা তা দেখতে পারেন।\n• কার্বন, অপচয়, সোলার ও PDF হিসাবের জন্য প্রয়োজনীয় সংখ্যাগুলো আমাদের সার্ভারে পাঠানো হয়; সেখানে কিছুই সংরক্ষণ করা হয় না।';

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
      'বিল পড়ার জন্য কাটা ছবিটি আমাদের সার্ভারে এবং Google-এর Gemini API-তে পাঠানো হবে। ক্রপ করার সময় নাম, ঠিকানা, গ্রাহক/কনজিউমার নম্বর ও মিটার নম্বর কেটে বাদ দিন। আমাদের সার্ভারে ছবি সংরক্ষণ করা হয় না। Google-এর বিনামূল্যের সংস্করণে Google আপলোড তার পণ্য উন্নয়নে ব্যবহার করতে পারে এবং কর্মীরা তা দেখতে পারেন।';

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
  String get homeWaste => 'বিদ্যুৎ অপচয় যাচাই';

  @override
  String get homeCarbon => 'কার্বন রিপোর্ট';

  @override
  String homeBillsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বিল সংরক্ষিত',
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
  String get cropTitle => 'বিলের ছবি কাটুন (ক্রপ)';

  @override
  String get cropReminder =>
      'নাম, ঠিকানা, গ্রাহক/কনজিউমার নম্বর ও মিটার নম্বর কেটে বাদ দিন। ব্যবহৃত ইউনিট, টাকার পরিমাণ ও তারিখ রাখুন।';

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
    return 'উৎপাদিত পরিমাণ ($unit)';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস ইমপোর্টের জন্য প্রস্তুত',
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস ইমপোর্ট হয়েছে',
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
    return '$value টন CO2e';
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
  String get exportPdf => 'PDF রপ্তানি';

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
  String get wasteTitle => 'বিদ্যুৎ অপচয় যাচাই';

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
    return '$month মাসে উৎপাদনের তুলনায় প্রত্যাশার চেয়ে প্রায় $pct% বেশি বিদ্যুৎ ব্যবহার হয়েছে; প্রায় $kwh kWh$cost। কম্প্রেসর, অকারণে চালু থাকা মেশিন ও জেনারেটর চেঞ্জওভার পরীক্ষা করুন।';
  }

  @override
  String wasteFlagMessageMad(
    String month,
    String pct,
    String kwh,
    String cost,
  ) {
    return '$month মাসে সাধারণ মাসের চেয়ে প্রায় $pct% বেশি বিদ্যুৎ ব্যবহার হয়েছে; প্রায় $kwh kWh$cost। কম্প্রেসর, অকারণে চালু থাকা মেশিন ও জেনারেটর চেঞ্জওভার পরীক্ষা করুন।';
  }

  @override
  String wasteCostPart(String amount) {
    return ', প্রায় $amount টাকা';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস চিহ্নিত',
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
      'মানচিত্রে ছাদের কোণগুলোতে ট্যাপ করুন। ভুল হলে ফেরত বোতাম চাপুন।';

  @override
  String solarPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কোণ',
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
  String get solarParamsTitle => 'প্যারামিটার';

  @override
  String get paramUsableRoof => 'ব্যবহারযোগ্য ছাদের অংশ';

  @override
  String get paramM2PerKwp => 'প্রতি kWp-এ m²';

  @override
  String get paramPerformanceRatio => 'পারফরম্যান্স রেশিও';

  @override
  String get paramDegradation => 'প্যানেলের বার্ষিক দক্ষতা হ্রাস';

  @override
  String get paramCapex => 'বিনিয়োগ (প্রতি kWp টাকা, ঐচ্ছিক)';

  @override
  String get paramOm => 'রক্ষণাবেক্ষণ (বিনিয়োগের বার্ষিক অংশ, ঐচ্ছিক)';

  @override
  String get paramPrice => 'বিদ্যুতের দাম (টাকা/kWh, ঐচ্ছিক)';

  @override
  String get paramPriceHint => 'ডিফল্ট: আপনার বিলের গড়';

  @override
  String get paramExportPrice => 'রপ্তানি মূল্য (টাকা/kWh, ঐচ্ছিক)';

  @override
  String get paramNetMetering => 'নেট মিটারিং';

  @override
  String get paramPsh => 'পিক সান আওয়ার (ঐচ্ছিক)';

  @override
  String get paramPshHint => 'NASA POWER তথ্য ব্যবহার করতে খালি রাখুন';

  @override
  String paramDefault(String value) {
    return 'ডিফল্ট $value';
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
  String get solarFinancials => 'আর্থিক হিসাব';

  @override
  String get solarCapex => 'বিনিয়োগ';

  @override
  String get solarYear1Savings => 'প্রথম বছরের সাশ্রয়';

  @override
  String get solarYear1Om => 'প্রথম বছরের রক্ষণাবেক্ষণ';

  @override
  String get solarPayback => 'বিনিয়োগ ফেরতের সময়';

  @override
  String get solarNoPayback => 'বিনিয়োগ ফেরত আসে না';

  @override
  String get solarNoFinancials =>
      'সাশ্রয় ও বিনিয়োগ ফেরতের সময় দেখতে প্রতি kWp বিনিয়োগ লিখুন।';

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
      'প্রাক-সম্ভাব্যতা অনুমান। ছাদের ভার বহন ক্ষমতা, ছায়া ও বৈদ্যুতিক নকশার জন্য পেশাদার মূল্যায়ন প্রয়োজন।';

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
      '• শুধু ইউটিলিটি বিল থেকে স্কোপ ১ ও ২। স্কোপ ৩ নেই; হাতে না লিখলে কয়লা, বায়োমাস বা অন্য জ্বালানি অন্তর্ভুক্ত নয়।\n• বিল পড়ার নির্ভুলতা মাত্র কয়েকটি নমুনা বিলে মাপা হয়েছে। সবসময় মান যাচাই করুন।\n• অপচয় যাচাই উৎপাদনের বিপরীতে পরিসংখ্যানগত ব্যতিক্রম চিহ্নিত করে; কারণ শনাক্ত করতে পারে না।\n• সোলার ফলাফল শুধু প্রাক-সম্ভাব্যতা অনুমান।\n• নির্গমন ফ্যাক্টর প্রকাশিত সরকারি উৎস থেকে নেওয়া (উৎস ও সাল রিপোর্টে দেওয়া আছে); নতুন সংস্করণ প্রকাশ হলে হালনাগাদ করুন এবং ক্রেতার নিয়মের সাথে মিলিয়ে নিন।\n• অ্যাপ টোকেন দুর্বল সুরক্ষা, শুধু ডেমোর জন্য যথেষ্ট।';

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
  String get stepWaste => 'বিদ্যুৎ অপচয় যাচাই করুন';

  @override
  String get homeStatMonths => 'তথ্যসহ মাস';

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
      'ছবি তুলুন বা বেছে নিন। সংরক্ষণের আগে ব্যক্তিগত তথ্য কেটে বাদ দেবেন এবং প্রতিটি মান যাচাই করবেন।';

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
}
