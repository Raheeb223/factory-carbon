import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory Energy & Carbon'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get navBills;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSolar.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get navSolar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @syntheticBadge.
  ///
  /// In en, this message translates to:
  /// **'SYNTHETIC DATA'**
  String get syntheticBadge;

  /// No description provided for @syntheticBanner.
  ///
  /// In en, this message translates to:
  /// **'This app contains synthetic demo data. Results do not describe a real factory.'**
  String get syntheticBanner;

  /// No description provided for @unverifiedFactorBadge.
  ///
  /// In en, this message translates to:
  /// **'Unverified factor'**
  String get unverifiedFactorBadge;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @showingSaved.
  ///
  /// In en, this message translates to:
  /// **'Showing the saved result. Update it when you are online.'**
  String get showingSaved;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your internet connection and the server address in Settings.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond.'**
  String get errorTimeout;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Please try again.'**
  String get errorServer;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available on the server right now.'**
  String get errorUnavailable;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @invalidNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Must be zero or more'**
  String get invalidNonNegative;

  /// No description provided for @invalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get invalidLatitude;

  /// No description provided for @invalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get invalidLongitude;

  /// No description provided for @invalidFraction.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 0 and 1'**
  String get invalidFraction;

  /// No description provided for @invalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Select a month'**
  String get invalidMonth;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your factory'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Turn utility bills into a carbon report for buyers, get warnings about high electricity use and estimate rooftop solar.'**
  String get onboardingIntro;

  /// No description provided for @factoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Factory name'**
  String get factoryNameLabel;

  /// No description provided for @factoryLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (city, district)'**
  String get factoryLocationLabel;

  /// No description provided for @factoryLatLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude (optional)'**
  String get factoryLatLabel;

  /// No description provided for @factoryLonLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude (optional)'**
  String get factoryLonLabel;

  /// No description provided for @productionUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Production unit (e.g. pieces)'**
  String get productionUnitLabel;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data and privacy'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'• Your factory profile, bills, production and reports are stored only on this phone.\n• When you scan a bill, the cropped photo is sent to our server and to Google\'s Gemini API to read the values. Crop out names, addresses and consumer or meter numbers first.\n• Our server does not store your photos or data. Google handles uploads under its Gemini API terms: if the server uses Google\'s free tier, Google may use uploads to improve its products and people at Google may review them.\n• Carbon, waste, solar and PDF calculations send the needed numbers to our server; nothing is stored there.'**
  String get privacyBody;

  /// No description provided for @privacyAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I have read and understand how my data is handled'**
  String get privacyAcknowledge;

  /// No description provided for @privacyMustAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you have read the privacy notice.'**
  String get privacyMustAcknowledge;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @uploadNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Before your first upload'**
  String get uploadNoticeTitle;

  /// No description provided for @uploadNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'The photo will be sent to our server and to Google\'s Gemini API to read the bill. Before sending, you crop the bill and cover names, addresses, consumer and meter numbers with black boxes. Photos are not stored on our server. On Google\'s free tier, Google may use uploads to improve its products and people may review them.'**
  String get uploadNoticeBody;

  /// No description provided for @uploadNoticeAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand, continue'**
  String get uploadNoticeAccept;

  /// No description provided for @homeLatestReport.
  ///
  /// In en, this message translates to:
  /// **'Latest carbon report'**
  String get homeLatestReport;

  /// No description provided for @homeNoReport.
  ///
  /// In en, this message translates to:
  /// **'No report yet. Add bills or import history, then open Reports.'**
  String get homeNoReport;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeImportHistory.
  ///
  /// In en, this message translates to:
  /// **'Import history (CSV)'**
  String get homeImportHistory;

  /// No description provided for @homeProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get homeProduction;

  /// No description provided for @homeWaste.
  ///
  /// In en, this message translates to:
  /// **'Electricity waste check'**
  String get homeWaste;

  /// No description provided for @homeCarbon.
  ///
  /// In en, this message translates to:
  /// **'Carbon report'**
  String get homeCarbon;

  /// No description provided for @homeBillsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bills saved} =1{1 bill saved} other{{count} bills saved}}'**
  String homeBillsCount(int count);

  /// No description provided for @addBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Add bill'**
  String get addBillTitle;

  /// No description provided for @addBillCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get addBillCamera;

  /// No description provided for @addBillGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get addBillGallery;

  /// No description provided for @addBillManual.
  ///
  /// In en, this message translates to:
  /// **'Enter manually (no image)'**
  String get addBillManual;

  /// No description provided for @addBillManualHint.
  ///
  /// In en, this message translates to:
  /// **'For diesel receipts, unmetered gas, or when a photo cannot be read.'**
  String get addBillManualHint;

  /// No description provided for @cropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop the bill'**
  String get cropTitle;

  /// No description provided for @cropReminder.
  ///
  /// In en, this message translates to:
  /// **'First trim the photo to the bill. In the next step you can cover any names, addresses, consumer or meter numbers that are inside it.'**
  String get cropReminder;

  /// No description provided for @preparingImage.
  ///
  /// In en, this message translates to:
  /// **'Preparing image…'**
  String get preparingImage;

  /// No description provided for @uploadProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploadProgress(String percent);

  /// No description provided for @uploadReading.
  ///
  /// In en, this message translates to:
  /// **'Reading values. This can take up to a minute.'**
  String get uploadReading;

  /// No description provided for @uploadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not read the bill'**
  String get uploadFailedTitle;

  /// No description provided for @uploadEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually instead'**
  String get uploadEnterManually;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the values'**
  String get reviewTitle;

  /// No description provided for @reviewIntro.
  ///
  /// In en, this message translates to:
  /// **'Values were read automatically. Compare each one with the image. Highlighted fields need extra care.'**
  String get reviewIntro;

  /// No description provided for @reviewManualIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the values from your bill or receipt.'**
  String get reviewManualIntro;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence: check this on the image'**
  String get lowConfidence;

  /// No description provided for @fieldBillType.
  ///
  /// In en, this message translates to:
  /// **'Bill type'**
  String get fieldBillType;

  /// No description provided for @billTypeElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get billTypeElectricity;

  /// No description provided for @billTypeGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get billTypeGas;

  /// No description provided for @billTypeDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get billTypeDiesel;

  /// No description provided for @billTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get billTypeUnknown;

  /// No description provided for @fieldUtilityName.
  ///
  /// In en, this message translates to:
  /// **'Utility / supplier'**
  String get fieldUtilityName;

  /// No description provided for @fieldBillingMonth.
  ///
  /// In en, this message translates to:
  /// **'Billing month'**
  String get fieldBillingMonth;

  /// No description provided for @fieldPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Period start'**
  String get fieldPeriodStart;

  /// No description provided for @fieldPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Period end'**
  String get fieldPeriodEnd;

  /// No description provided for @fieldConsumedUnits.
  ///
  /// In en, this message translates to:
  /// **'Consumed units'**
  String get fieldConsumedUnits;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// No description provided for @fieldTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total payable (Tk)'**
  String get fieldTotalAmount;

  /// No description provided for @fieldTariffCode.
  ///
  /// In en, this message translates to:
  /// **'Tariff code'**
  String get fieldTariffCode;

  /// No description provided for @fieldSanctionedLoad.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned load (kW)'**
  String get fieldSanctionedLoad;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes from the reader'**
  String get fieldNotes;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @selectBillType.
  ///
  /// In en, this message translates to:
  /// **'Select the bill type'**
  String get selectBillType;

  /// No description provided for @unitMismatch.
  ///
  /// In en, this message translates to:
  /// **'Unit must be {unit} for this bill type'**
  String unitMismatch(String unit);

  /// No description provided for @reviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'I have checked these values against the bill'**
  String get reviewConfirm;

  /// No description provided for @reviewMustConfirm.
  ///
  /// In en, this message translates to:
  /// **'Tick the box to confirm you checked the values.'**
  String get reviewMustConfirm;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get duplicateTitle;

  /// No description provided for @duplicateBody.
  ///
  /// In en, this message translates to:
  /// **'A {type} bill for {month} is already saved. Save this one too?'**
  String duplicateBody(String type, String month);

  /// No description provided for @duplicateSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get duplicateSaveAnyway;

  /// No description provided for @billSaved.
  ///
  /// In en, this message translates to:
  /// **'Bill saved'**
  String get billSaved;

  /// No description provided for @imageWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'The photo is deleted from this phone after saving.'**
  String get imageWillBeDeleted;

  /// No description provided for @imageWillBeKept.
  ///
  /// In en, this message translates to:
  /// **'The photo is kept on this phone (Settings).'**
  String get imageWillBeKept;

  /// No description provided for @warnUnknownBillType.
  ///
  /// In en, this message translates to:
  /// **'Bill type could not be identified. Please select it.'**
  String get warnUnknownBillType;

  /// No description provided for @warnPeriodEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Period end is before period start.'**
  String get warnPeriodEndBeforeStart;

  /// No description provided for @warnUnusualPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'The billing period length is unusual for a monthly bill.'**
  String get warnUnusualPeriodLength;

  /// No description provided for @warnMonthPeriodMismatch.
  ///
  /// In en, this message translates to:
  /// **'Billing month does not match the period end date.'**
  String get warnMonthPeriodMismatch;

  /// No description provided for @warnUnitsNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Consumed units should be greater than zero.'**
  String get warnUnitsNotPositive;

  /// No description provided for @warnUnitsAboveCeiling.
  ///
  /// In en, this message translates to:
  /// **'Consumed units are unusually high. Please check.'**
  String get warnUnitsAboveCeiling;

  /// No description provided for @warnUnitTypeMismatch.
  ///
  /// In en, this message translates to:
  /// **'This unit is unusual for this bill type.'**
  String get warnUnitTypeMismatch;

  /// No description provided for @warnPriceOutOfBand.
  ///
  /// In en, this message translates to:
  /// **'Amount per unit is outside the usual range. Check the units and the amount.'**
  String get warnPriceOutOfBand;

  /// No description provided for @warnLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'The reader was not confident about this value. Check it on the image.'**
  String get warnLowConfidence;

  /// No description provided for @billsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get billsTitle;

  /// No description provided for @billsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bills yet. Add a bill or import history.'**
  String get billsEmpty;

  /// No description provided for @billOriginImage.
  ///
  /// In en, this message translates to:
  /// **'From photo'**
  String get billOriginImage;

  /// No description provided for @billOriginManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get billOriginManual;

  /// No description provided for @billOriginImported.
  ///
  /// In en, this message translates to:
  /// **'Imported (not from a bill image)'**
  String get billOriginImported;

  /// No description provided for @billOriginDemo.
  ///
  /// In en, this message translates to:
  /// **'Synthetic'**
  String get billOriginDemo;

  /// No description provided for @billEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get billEdited;

  /// No description provided for @deleteBillConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this bill?'**
  String get deleteBillConfirm;

  /// No description provided for @editBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get editBillTitle;

  /// No description provided for @productionTitle.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get productionTitle;

  /// No description provided for @productionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No production data yet.'**
  String get productionEmpty;

  /// No description provided for @productionMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get productionMonth;

  /// No description provided for @productionUnits.
  ///
  /// In en, this message translates to:
  /// **'Units produced ({unit})'**
  String productionUnits(String unit);

  /// No description provided for @productionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add production'**
  String get productionAdd;

  /// No description provided for @productionReplaceNote.
  ///
  /// In en, this message translates to:
  /// **'Saving a month that already exists replaces its value.'**
  String get productionReplaceNote;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import history'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Fill 12–24 months in the template: month, electricity kWh, diesel litres, gas m³ and production (electricity cost is optional). Then import it here.'**
  String get importIntro;

  /// No description provided for @importGetTemplate.
  ///
  /// In en, this message translates to:
  /// **'Get template'**
  String get importGetTemplate;

  /// No description provided for @importPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get importPickFile;

  /// No description provided for @importRowsReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ready to import} other{{count} months ready to import}}'**
  String importRowsReady(int count);

  /// No description provided for @importErrors.
  ///
  /// In en, this message translates to:
  /// **'Fix these problems and choose the file again:'**
  String get importErrors;

  /// No description provided for @importWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get importWarnings;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirm;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month imported} other{{count} months imported}}'**
  String importDone(int count);

  /// No description provided for @importMarked.
  ///
  /// In en, this message translates to:
  /// **'Imported rows are marked \"imported (not from a bill image)\" and listed in data-quality notes.'**
  String get importMarked;

  /// No description provided for @importFewMonths.
  ///
  /// In en, this message translates to:
  /// **'Fewer than 12 months: the waste check needs at least 6, a full year is better.'**
  String get importFewMonths;

  /// No description provided for @issueMissingColumns.
  ///
  /// In en, this message translates to:
  /// **'Missing columns: {columns}'**
  String issueMissingColumns(String columns);

  /// No description provided for @issueNoRows.
  ///
  /// In en, this message translates to:
  /// **'The file has no data rows.'**
  String get issueNoRows;

  /// No description provided for @issueBadMonth.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: month \"{value}\" must be YYYY-MM'**
  String issueBadMonth(String row, String value);

  /// No description provided for @issueBadNumber.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: {column} \"{value}\" is not a number'**
  String issueBadNumber(String row, String column, String value);

  /// No description provided for @issueNegative.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: {column} cannot be negative'**
  String issueNegative(String row, String column);

  /// No description provided for @issueDuplicateMonth.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: month {value} appears more than once'**
  String issueDuplicateMonth(String row, String value);

  /// No description provided for @issueEmptyRow.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: no values for {value}; skipped'**
  String issueEmptyRow(String row, String value);

  /// No description provided for @issueCostWithoutKwh.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: cost without kWh for {value}; cost ignored'**
  String issueCostWithoutKwh(String row, String value);

  /// No description provided for @importColMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get importColMonth;

  /// No description provided for @importColKwh.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get importColKwh;

  /// No description provided for @importColDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel L'**
  String get importColDiesel;

  /// No description provided for @importColGas.
  ///
  /// In en, this message translates to:
  /// **'Gas m³'**
  String get importColGas;

  /// No description provided for @importColProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get importColProduction;

  /// No description provided for @carbonTitle.
  ///
  /// In en, this message translates to:
  /// **'Carbon report'**
  String get carbonTitle;

  /// No description provided for @carbonCalculate.
  ///
  /// In en, this message translates to:
  /// **'Update report'**
  String get carbonCalculate;

  /// No description provided for @carbonNoData.
  ///
  /// In en, this message translates to:
  /// **'No confirmed data yet. Add bills or import history.'**
  String get carbonNoData;

  /// No description provided for @carbonScope1.
  ///
  /// In en, this message translates to:
  /// **'Scope 1 (diesel + gas)'**
  String get carbonScope1;

  /// No description provided for @carbonScope2.
  ///
  /// In en, this message translates to:
  /// **'Scope 2 (grid electricity)'**
  String get carbonScope2;

  /// No description provided for @carbonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get carbonTotal;

  /// No description provided for @carbonIntensity.
  ///
  /// In en, this message translates to:
  /// **'Per 1,000 {unit}'**
  String carbonIntensity(String unit);

  /// No description provided for @tonnesCo2e.
  ///
  /// In en, this message translates to:
  /// **'{value} tCO2e'**
  String tonnesCo2e(String value);

  /// No description provided for @carbonMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly emissions'**
  String get carbonMonthly;

  /// No description provided for @carbonPartialMonth.
  ///
  /// In en, this message translates to:
  /// **'* partial month (missing data or factor). Empty months have no data; they are not zero.'**
  String get carbonPartialMonth;

  /// No description provided for @carbonFactorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emission factors'**
  String get carbonFactorsTitle;

  /// No description provided for @carbonQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Data quality'**
  String get carbonQualityTitle;

  /// No description provided for @carbonFactorNotSet.
  ///
  /// In en, this message translates to:
  /// **'The {factor} emission factor is not set on the server, so these emissions are not calculated.'**
  String carbonFactorNotSet(String factor);

  /// No description provided for @factorGrid.
  ///
  /// In en, this message translates to:
  /// **'grid electricity'**
  String get factorGrid;

  /// No description provided for @factorDiesel.
  ///
  /// In en, this message translates to:
  /// **'diesel'**
  String get factorDiesel;

  /// No description provided for @factorGas.
  ///
  /// In en, this message translates to:
  /// **'natural gas'**
  String get factorGas;

  /// No description provided for @factorStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get factorStatusVerified;

  /// No description provided for @factorSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String factorSource(String source);

  /// No description provided for @factorYear.
  ///
  /// In en, this message translates to:
  /// **'Year: {year}'**
  String factorYear(String year);

  /// No description provided for @legendElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get legendElectricity;

  /// No description provided for @legendDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get legendDiesel;

  /// No description provided for @legendGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get legendGas;

  /// No description provided for @monthsSummary.
  ///
  /// In en, this message translates to:
  /// **'{withData} of {total} months have data, {complete} complete'**
  String monthsSummary(String withData, String total, String complete);

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportRaw.
  ///
  /// In en, this message translates to:
  /// **'Export raw data (CSV)'**
  String get exportRaw;

  /// No description provided for @exportNeedsResult.
  ///
  /// In en, this message translates to:
  /// **'Update the report first.'**
  String get exportNeedsResult;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get exporting;

  /// No description provided for @methodologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Methodology'**
  String get methodologyTitle;

  /// No description provided for @methodologyBody.
  ///
  /// In en, this message translates to:
  /// **'Scope 2 (location-based) = electricity kWh × grid emission factor. Scope 1 = diesel litres × diesel factor + gas m³ × gas factor. Results are in tonnes CO2e. Intensity is shown only for complete months with production.'**
  String get methodologyBody;

  /// No description provided for @noteMissingData.
  ///
  /// In en, this message translates to:
  /// **'No {source} data for these months. They are shown as empty, not zero.'**
  String noteMissingData(String source);

  /// No description provided for @noteMonthsWithoutData.
  ///
  /// In en, this message translates to:
  /// **'No energy data at all for these months.'**
  String get noteMonthsWithoutData;

  /// No description provided for @noteMissingProduction.
  ///
  /// In en, this message translates to:
  /// **'Production is missing for these months, so intensity is not shown.'**
  String get noteMissingProduction;

  /// No description provided for @noteMultipleEntries.
  ///
  /// In en, this message translates to:
  /// **'More than one entry of the same type in these months; quantities were added. Check for duplicates.'**
  String get noteMultipleEntries;

  /// No description provided for @noteUserEdited.
  ///
  /// In en, this message translates to:
  /// **'Some values were corrected by you after automatic reading.'**
  String get noteUserEdited;

  /// No description provided for @noteManualEntries.
  ///
  /// In en, this message translates to:
  /// **'Some entries were typed in manually without a bill image.'**
  String get noteManualEntries;

  /// No description provided for @noteImportedHistory.
  ///
  /// In en, this message translates to:
  /// **'Some data was imported from a spreadsheet (not from a bill image).'**
  String get noteImportedHistory;

  /// No description provided for @noteSyntheticData.
  ///
  /// In en, this message translates to:
  /// **'SYNTHETIC demo data is included. These results do not describe a real factory.'**
  String get noteSyntheticData;

  /// No description provided for @notePlaceholderFactors.
  ///
  /// In en, this message translates to:
  /// **'Unverified (PLACEHOLDER) emission factors are in use. Verify them before any real submission.'**
  String get notePlaceholderFactors;

  /// No description provided for @noteIncompleteTotals.
  ///
  /// In en, this message translates to:
  /// **'Totals include months with missing sources or factors, so they understate the true footprint.'**
  String get noteIncompleteTotals;

  /// No description provided for @noteNoData.
  ///
  /// In en, this message translates to:
  /// **'No confirmed bills or production data.'**
  String get noteNoData;

  /// No description provided for @wasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity waste check'**
  String get wasteTitle;

  /// No description provided for @wasteAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get wasteAnalyze;

  /// No description provided for @wasteInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Only {count} months of electricity data. At least {required} months are needed.'**
  String wasteInsufficient(String count, String required);

  /// No description provided for @wasteImportPrompt.
  ///
  /// In en, this message translates to:
  /// **'Import past bills'**
  String get wasteImportPrompt;

  /// No description provided for @wasteMethodOls.
  ///
  /// In en, this message translates to:
  /// **'Expected use is based on your production level.'**
  String get wasteMethodOls;

  /// No description provided for @wasteMethodMad.
  ///
  /// In en, this message translates to:
  /// **'Lower confidence, no production data: compared with a typical month.'**
  String get wasteMethodMad;

  /// No description provided for @wasteActual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get wasteActual;

  /// No description provided for @wasteExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get wasteExpected;

  /// No description provided for @wasteBand.
  ///
  /// In en, this message translates to:
  /// **'Normal range (95%)'**
  String get wasteBand;

  /// No description provided for @wasteFlagMessage.
  ///
  /// In en, this message translates to:
  /// **'{month} used about {pct}% more electricity than expected for the units produced; about {kwh} kWh{cost}. Check compressors, idle machines and generator changeover.'**
  String wasteFlagMessage(String month, String pct, String kwh, String cost);

  /// No description provided for @wasteFlagMessageMad.
  ///
  /// In en, this message translates to:
  /// **'{month} used about {pct}% more electricity than a typical month; about {kwh} kWh{cost}. Check compressors, idle machines and generator changeover.'**
  String wasteFlagMessageMad(String month, String pct, String kwh, String cost);

  /// No description provided for @wasteCostPart.
  ///
  /// In en, this message translates to:
  /// **', about Tk {amount}'**
  String wasteCostPart(String amount);

  /// No description provided for @wasteNoCost.
  ///
  /// In en, this message translates to:
  /// **' (cost unknown: no bill amounts)'**
  String get wasteNoCost;

  /// No description provided for @wasteNoFlags.
  ///
  /// In en, this message translates to:
  /// **'No month used clearly more electricity than expected.'**
  String get wasteNoFlags;

  /// No description provided for @wasteHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How this works and its limits'**
  String get wasteHowTitle;

  /// No description provided for @wasteHowBody.
  ///
  /// In en, this message translates to:
  /// **'With at least 6 months of electricity and production data, the app fits a straight line of kWh against production. For each month it predicts the expected kWh from the other months and a 95% range. Months above the range are flagged.\n\nWithout production data it compares each month with your typical month. This is less reliable.\n\nLimits:\n• Only monthly totals, a small sample: results are indicative.\n• Without sub-metering it cannot tell which machine used the extra electricity.\n• It flags statistical outliers; it cannot identify the cause.\n• Product mix, working hours, weather or new machines can explain a flag.'**
  String get wasteHowBody;

  /// No description provided for @wasteFlaggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No months flagged} =1{1 month flagged} other{{count} months flagged}}'**
  String wasteFlaggedCount(int count);

  /// No description provided for @solarTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooftop solar'**
  String get solarTitle;

  /// No description provided for @solarNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get solarNewPlan;

  /// No description provided for @solarNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No saved plans. Draw your roof to start.'**
  String get solarNoPlans;

  /// No description provided for @solarDrawHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the roof corners on the map. Use undo to fix mistakes.'**
  String get solarDrawHint;

  /// No description provided for @solarPoints.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 corner} other{{count} corners}}'**
  String solarPoints(int count);

  /// No description provided for @solarNeedPoints.
  ///
  /// In en, this message translates to:
  /// **'Tap at least 3 corners.'**
  String get solarNeedPoints;

  /// No description provided for @solarLayerStreet.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get solarLayerStreet;

  /// No description provided for @solarLayerSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get solarLayerSatellite;

  /// No description provided for @solarSatelliteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Satellite imagery is not configured. Building outlines are visible on the map at high zoom.'**
  String get solarSatelliteUnavailable;

  /// No description provided for @solarParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get solarParamsTitle;

  /// No description provided for @paramUsableRoof.
  ///
  /// In en, this message translates to:
  /// **'Usable roof fraction'**
  String get paramUsableRoof;

  /// No description provided for @paramM2PerKwp.
  ///
  /// In en, this message translates to:
  /// **'m² per kWp'**
  String get paramM2PerKwp;

  /// No description provided for @paramPerformanceRatio.
  ///
  /// In en, this message translates to:
  /// **'Performance ratio'**
  String get paramPerformanceRatio;

  /// No description provided for @paramDegradation.
  ///
  /// In en, this message translates to:
  /// **'Degradation per year'**
  String get paramDegradation;

  /// No description provided for @paramCapex.
  ///
  /// In en, this message translates to:
  /// **'Capex (Tk per kWp, optional)'**
  String get paramCapex;

  /// No description provided for @paramOm.
  ///
  /// In en, this message translates to:
  /// **'O&M (fraction of capex per year, optional)'**
  String get paramOm;

  /// No description provided for @paramPrice.
  ///
  /// In en, this message translates to:
  /// **'Electricity price (Tk/kWh, optional)'**
  String get paramPrice;

  /// No description provided for @paramPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Default: average from your bills'**
  String get paramPriceHint;

  /// No description provided for @paramExportPrice.
  ///
  /// In en, this message translates to:
  /// **'Export price (Tk/kWh, optional)'**
  String get paramExportPrice;

  /// No description provided for @paramNetMetering.
  ///
  /// In en, this message translates to:
  /// **'Net metering'**
  String get paramNetMetering;

  /// No description provided for @paramPsh.
  ///
  /// In en, this message translates to:
  /// **'Peak sun hours (optional)'**
  String get paramPsh;

  /// No description provided for @paramPshHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use NASA POWER data'**
  String get paramPshHint;

  /// No description provided for @paramDefault.
  ///
  /// In en, this message translates to:
  /// **'Default {value}'**
  String paramDefault(String value);

  /// No description provided for @solarEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get solarEstimate;

  /// No description provided for @solarResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Solar estimate'**
  String get solarResultTitle;

  /// No description provided for @solarRoofArea.
  ///
  /// In en, this message translates to:
  /// **'Roof area'**
  String get solarRoofArea;

  /// No description provided for @solarUsableArea.
  ///
  /// In en, this message translates to:
  /// **'Usable area'**
  String get solarUsableArea;

  /// No description provided for @solarSize.
  ///
  /// In en, this message translates to:
  /// **'System size'**
  String get solarSize;

  /// No description provided for @solarAnnualGen.
  ///
  /// In en, this message translates to:
  /// **'Annual generation'**
  String get solarAnnualGen;

  /// No description provided for @solarOffset.
  ///
  /// In en, this message translates to:
  /// **'Share of consumption offset'**
  String get solarOffset;

  /// No description provided for @solarCo2.
  ///
  /// In en, this message translates to:
  /// **'CO2 avoided per year'**
  String get solarCo2;

  /// No description provided for @solarPsh.
  ///
  /// In en, this message translates to:
  /// **'Peak sun hours (average)'**
  String get solarPsh;

  /// No description provided for @solarSourceNasa.
  ///
  /// In en, this message translates to:
  /// **'NASA POWER'**
  String get solarSourceNasa;

  /// No description provided for @solarSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get solarSourceManual;

  /// No description provided for @solarFinancials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get solarFinancials;

  /// No description provided for @solarCapex.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get solarCapex;

  /// No description provided for @solarYear1Savings.
  ///
  /// In en, this message translates to:
  /// **'Year-1 savings'**
  String get solarYear1Savings;

  /// No description provided for @solarYear1Om.
  ///
  /// In en, this message translates to:
  /// **'Year-1 O&M'**
  String get solarYear1Om;

  /// No description provided for @solarPayback.
  ///
  /// In en, this message translates to:
  /// **'Simple payback'**
  String get solarPayback;

  /// No description provided for @solarNoPayback.
  ///
  /// In en, this message translates to:
  /// **'No payback'**
  String get solarNoPayback;

  /// No description provided for @solarNoFinancials.
  ///
  /// In en, this message translates to:
  /// **'Enter a capex per kWp to see savings and payback.'**
  String get solarNoFinancials;

  /// No description provided for @solarCashflow.
  ///
  /// In en, this message translates to:
  /// **'Cumulative cash flow (million Tk)'**
  String get solarCashflow;

  /// No description provided for @solarSavePlan.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get solarSavePlan;

  /// No description provided for @solarPlanName.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get solarPlanName;

  /// No description provided for @solarPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Plan saved'**
  String get solarPlanSaved;

  /// No description provided for @solarNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get solarNotes;

  /// No description provided for @solarDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Pre-feasibility estimate. Structural load, shading and electrical design need a professional assessment.'**
  String get solarDisclaimer;

  /// No description provided for @valueYears.
  ///
  /// In en, this message translates to:
  /// **'{value} years'**
  String valueYears(String value);

  /// No description provided for @valueKwp.
  ///
  /// In en, this message translates to:
  /// **'{value} kWp'**
  String valueKwp(String value);

  /// No description provided for @valueKwhYear.
  ///
  /// In en, this message translates to:
  /// **'{value} kWh/year'**
  String valueKwhYear(String value);

  /// No description provided for @valueM2.
  ///
  /// In en, this message translates to:
  /// **'{value} m²'**
  String valueM2(String value);

  /// No description provided for @valueTk.
  ///
  /// In en, this message translates to:
  /// **'Tk {value}'**
  String valueTk(String value);

  /// No description provided for @valuePercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String valuePercent(String value);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @settingsKeepImages.
  ///
  /// In en, this message translates to:
  /// **'Keep bill images on this phone'**
  String get settingsKeepImages;

  /// No description provided for @settingsKeepImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Off: photos are deleted once the values are read.'**
  String get settingsKeepImagesHint;

  /// No description provided for @settingsFactory.
  ///
  /// In en, this message translates to:
  /// **'Factory profile'**
  String get settingsFactory;

  /// No description provided for @settingsDataHandling.
  ///
  /// In en, this message translates to:
  /// **'How your data is handled'**
  String get settingsDataHandling;

  /// No description provided for @settingsLimitations.
  ///
  /// In en, this message translates to:
  /// **'Known limitations'**
  String get settingsLimitations;

  /// No description provided for @settingsLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data (synthetic)'**
  String get settingsLoadDemo;

  /// No description provided for @settingsLoadDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Adds 24 months of made-up bills and production with 2 injected anomalies.'**
  String get settingsLoadDemoHint;

  /// No description provided for @settingsRemoveDemo.
  ///
  /// In en, this message translates to:
  /// **'Remove demo data'**
  String get settingsRemoveDemo;

  /// No description provided for @demoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Synthetic demo data loaded'**
  String get demoLoaded;

  /// No description provided for @demoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Demo data removed'**
  String get demoRemoved;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get settingsDeleteAll;

  /// No description provided for @deleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllConfirmTitle;

  /// No description provided for @deleteAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the factory profile, bills, production, solar plans, saved reports and kept images from this phone. It cannot be undone.'**
  String get deleteAllConfirmBody;

  /// No description provided for @deleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get deleteAllDone;

  /// No description provided for @settingsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// No description provided for @serverStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get serverStatusOk;

  /// No description provided for @serverStatusError.
  ///
  /// In en, this message translates to:
  /// **'Not reachable'**
  String get serverStatusError;

  /// No description provided for @serverExtractionOff.
  ///
  /// In en, this message translates to:
  /// **'Bill reading is not configured on the server; use manual entry.'**
  String get serverExtractionOff;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// No description provided for @dataHandlingTitle.
  ///
  /// In en, this message translates to:
  /// **'How your data is handled'**
  String get dataHandlingTitle;

  /// No description provided for @dataHandlingPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored on this phone'**
  String get dataHandlingPhoneTitle;

  /// No description provided for @dataHandlingPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Factory profile, confirmed bills, production, solar plans and the last calculated reports. Bill photos only if you turn on \"Keep bill images\". Delete everything any time in Settings.'**
  String get dataHandlingPhoneBody;

  /// No description provided for @dataHandlingServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to our server'**
  String get dataHandlingServerTitle;

  /// No description provided for @dataHandlingServerBody.
  ///
  /// In en, this message translates to:
  /// **'The cropped bill photo (to read it), and the numbers needed for each calculation: monthly quantities, amounts, production, roof outline. The server keeps nothing: no database, no stored images, no logged request contents.'**
  String get dataHandlingServerBody;

  /// No description provided for @dataHandlingGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to Google'**
  String get dataHandlingGoogleTitle;

  /// No description provided for @dataHandlingGoogleBody.
  ///
  /// In en, this message translates to:
  /// **'The cropped bill photo is passed to Google\'s Gemini API to read the values, under Google\'s Gemini API terms. On Google\'s free (unpaid) tier, Google may use the content to improve its products and human reviewers may read it; on a paid (billing-enabled) project it does not use it for that. Crop out personal details before uploading. The app never asks Gemini for names, addresses, consumer or meter numbers.'**
  String get dataHandlingGoogleBody;

  /// No description provided for @dataHandlingNasaTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to NASA POWER'**
  String get dataHandlingNasaTitle;

  /// No description provided for @dataHandlingNasaBody.
  ///
  /// In en, this message translates to:
  /// **'For solar estimates our server asks NASA POWER for sunlight data at the roof\'s approximate location (rounded). No other data is sent.'**
  String get dataHandlingNasaBody;

  /// No description provided for @limitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Known limitations'**
  String get limitationsTitle;

  /// No description provided for @limitationsBody.
  ///
  /// In en, this message translates to:
  /// **'• Scope 1 and 2 from utility bills only. No Scope 3; no coal, biomass or other fuels unless entered manually.\n• Bill-reading accuracy has only been measured on a few sample bills. Always check values.\n• The waste check flags statistical outliers against production; it cannot identify causes.\n• Solar results are pre-feasibility estimates only.\n• Emission factors come from published government sources (shown with source and year in the report). Update them when newer editions appear and confirm they match the buyer\'s rules.\n• The app token is weak protection, adequate for a demo only.'**
  String get limitationsBody;

  /// No description provided for @demoNeedsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Demo data can only be loaded when the app has no real bills or production. Export or delete your data first.'**
  String get demoNeedsEmpty;

  /// No description provided for @carbonStale.
  ///
  /// In en, this message translates to:
  /// **'Your data changed after this report was calculated. Update it.'**
  String get carbonStale;

  /// No description provided for @serverSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Server connection'**
  String get serverSettingsTitle;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverUrlLabel;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.20:8000 or https://api.example.com'**
  String get serverUrlHint;

  /// No description provided for @serverTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'App token'**
  String get serverTokenLabel;

  /// No description provided for @serverTest.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get serverTest;

  /// No description provided for @serverReset.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get serverReset;

  /// No description provided for @serverInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid address, e.g. 192.168.1.20:8000'**
  String get serverInvalidUrl;

  /// No description provided for @serverSaved.
  ///
  /// In en, this message translates to:
  /// **'Server settings saved'**
  String get serverSaved;

  /// No description provided for @serverTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connected to the server.'**
  String get serverTestOk;

  /// No description provided for @serverHelp.
  ///
  /// In en, this message translates to:
  /// **'Testing with your phone? Run start_backend.ps1 on your computer, connect the phone and the computer to the same Wi-Fi, then enter the address and token the script prints (for example 192.168.1.20:8000).'**
  String get serverHelp;

  /// No description provided for @serverCurrent.
  ///
  /// In en, this message translates to:
  /// **'Now using: {url}'**
  String serverCurrent(String url);

  /// No description provided for @languageChoose.
  ///
  /// In en, this message translates to:
  /// **'Language / ভাষা'**
  String get languageChoose;

  /// No description provided for @pickMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get pickMonth;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @homeGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get homeGettingStarted;

  /// No description provided for @stepAddData.
  ///
  /// In en, this message translates to:
  /// **'Add a bill or import past months'**
  String get stepAddData;

  /// No description provided for @stepProduction.
  ///
  /// In en, this message translates to:
  /// **'Enter monthly production'**
  String get stepProduction;

  /// No description provided for @stepReport.
  ///
  /// In en, this message translates to:
  /// **'Create your carbon report'**
  String get stepReport;

  /// No description provided for @stepWaste.
  ///
  /// In en, this message translates to:
  /// **'Check for electricity waste'**
  String get stepWaste;

  /// No description provided for @homeStatMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get homeStatMonths;

  /// No description provided for @homeStatLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest month'**
  String get homeStatLatest;

  /// No description provided for @homeTryDemo.
  ///
  /// In en, this message translates to:
  /// **'Just looking around? Load synthetic demo data to see every feature.'**
  String get homeTryDemo;

  /// No description provided for @homeLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get homeLoadDemo;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @reviewMainSection.
  ///
  /// In en, this message translates to:
  /// **'Main values'**
  String get reviewMainSection;

  /// No description provided for @reviewMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details (optional)'**
  String get reviewMoreDetails;

  /// No description provided for @reviewImageHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom the bill'**
  String get reviewImageHint;

  /// No description provided for @addBillScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a bill'**
  String get addBillScanTitle;

  /// No description provided for @addBillScanHint.
  ///
  /// In en, this message translates to:
  /// **'Take or choose a photo. You will hide personal details and check every value before saving.'**
  String get addBillScanHint;

  /// No description provided for @solarMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Go to factory location'**
  String get solarMyLocation;

  /// No description provided for @errInvalidPolygon.
  ///
  /// In en, this message translates to:
  /// **'The roof outline is not valid. Make sure its edges do not cross.'**
  String get errInvalidPolygon;

  /// No description provided for @errPolygonTooSmall.
  ///
  /// In en, this message translates to:
  /// **'The roof outline is too small. Zoom in and tap the roof corners.'**
  String get errPolygonTooSmall;

  /// No description provided for @errPolygonTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The roof outline is too large. Draw only the factory roof.'**
  String get errPolygonTooLarge;

  /// No description provided for @errUnitMismatch.
  ///
  /// In en, this message translates to:
  /// **'A saved entry has the wrong unit for its type. Fix it in Bills.'**
  String get errUnitMismatch;

  /// No description provided for @errIrradiance.
  ///
  /// In en, this message translates to:
  /// **'Could not get sunlight data. Enter peak sun hours manually or try again.'**
  String get errIrradiance;

  /// No description provided for @errDailyCap.
  ///
  /// In en, this message translates to:
  /// **'Today\'s bill-reading limit is reached. Try tomorrow or enter the bill manually.'**
  String get errDailyCap;

  /// No description provided for @errExtractionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the bill. Try a clearer photo or enter it manually.'**
  String get errExtractionFailed;

  /// No description provided for @errFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo is too large.'**
  String get errFileTooLarge;

  /// No description provided for @errUnsupportedFile.
  ///
  /// In en, this message translates to:
  /// **'Use a JPG, PNG or PDF file.'**
  String get errUnsupportedFile;

  /// No description provided for @errInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'The server rejected the app token. Check Server connection in Settings.'**
  String get errInvalidToken;

  /// No description provided for @errExtractionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bill reading is not set up on the server yet. Enter the bill manually.'**
  String get errExtractionUnavailable;

  /// No description provided for @swConsumptionPartial.
  ///
  /// In en, this message translates to:
  /// **'Your electricity history covers {count} of 12 months; the others use your average month.'**
  String swConsumptionPartial(String count);

  /// No description provided for @swExcessNotCounted.
  ///
  /// In en, this message translates to:
  /// **'About {kwh} kWh/year is more than you use in those months and is not counted (no net metering).'**
  String swExcessNotCounted(String kwh);

  /// No description provided for @swNoConsumption.
  ///
  /// In en, this message translates to:
  /// **'No electricity bills yet, so the share of use covered and savings cannot be estimated.'**
  String get swNoConsumption;

  /// No description provided for @swGridFactorNotSet.
  ///
  /// In en, this message translates to:
  /// **'The grid emission factor is not set on the server, so CO2 avoided is not calculated.'**
  String get swGridFactorNotSet;

  /// No description provided for @swCo2NeedsConsumption.
  ///
  /// In en, this message translates to:
  /// **'CO2 avoided needs your electricity history (or net metering).'**
  String get swCo2NeedsConsumption;

  /// No description provided for @swGridPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'CO2 avoided uses an unverified grid emission factor.'**
  String get swGridPlaceholder;

  /// No description provided for @swPriceMissing.
  ///
  /// In en, this message translates to:
  /// **'Savings need an electricity price: enter one, or add bills with amounts.'**
  String get swPriceMissing;

  /// No description provided for @swFinancialsNeedConsumption.
  ///
  /// In en, this message translates to:
  /// **'Savings need your electricity history when there is no net metering.'**
  String get swFinancialsNeedConsumption;

  /// No description provided for @swOmNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Maintenance (O&M) cost is not included.'**
  String get swOmNotIncluded;

  /// No description provided for @swExportPriceMissing.
  ///
  /// In en, this message translates to:
  /// **'Net metering is on but no export price is set; exported energy is valued at zero.'**
  String get swExportPriceMissing;

  /// No description provided for @swFinancialAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Assumes a constant electricity price and no loan cost.'**
  String get swFinancialAssumptions;

  /// No description provided for @swNoPayback.
  ///
  /// In en, this message translates to:
  /// **'Yearly savings do not cover maintenance, so there is no payback.'**
  String get swNoPayback;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introGetStarted;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Snap a bill. We read it.'**
  String get intro1Title;

  /// No description provided for @intro1Body.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your electricity, gas or diesel bill. AI reads the numbers, and you check them before anything is saved.'**
  String get intro1Body;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Carbon report in one tap'**
  String get intro2Title;

  /// No description provided for @intro2Body.
  ///
  /// In en, this message translates to:
  /// **'Get the Scope 1 + 2 carbon report your buyers ask for, ready to share as PDF or spreadsheet.'**
  String get intro2Body;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Cut waste. Go solar.'**
  String get intro3Title;

  /// No description provided for @intro3Body.
  ///
  /// In en, this message translates to:
  /// **'Spot months with unusually high electricity use, and estimate what rooftop solar could save you.'**
  String get intro3Body;

  /// No description provided for @introPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone.'**
  String get introPrivacyNote;

  /// No description provided for @onboardingFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few details for your reports. You can change them later.'**
  String get onboardingFormSubtitle;

  /// No description provided for @factoryCoordsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Used to centre the solar map on your factory.'**
  String get factoryCoordsHint;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeFootprint.
  ///
  /// In en, this message translates to:
  /// **'Carbon footprint'**
  String get homeFootprint;

  /// No description provided for @homeHeroEmpty.
  ///
  /// In en, this message translates to:
  /// **'Let\'s measure your factory\'s energy and carbon.'**
  String get homeHeroEmpty;

  /// No description provided for @homeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a bill'**
  String get homeScanTitle;

  /// No description provided for @homeScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of an electricity, gas or diesel bill. We read the numbers for you.'**
  String get homeScanSubtitle;

  /// No description provided for @homeExplore.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get homeExplore;

  /// No description provided for @tileBillsSub.
  ///
  /// In en, this message translates to:
  /// **'See and edit saved bills'**
  String get tileBillsSub;

  /// No description provided for @tileImportSub.
  ///
  /// In en, this message translates to:
  /// **'Add past months from a spreadsheet'**
  String get tileImportSub;

  /// No description provided for @tileProductionSub.
  ///
  /// In en, this message translates to:
  /// **'Monthly output for intensity'**
  String get tileProductionSub;

  /// No description provided for @tileCarbonSub.
  ///
  /// In en, this message translates to:
  /// **'Scope 1 + 2 report and PDF'**
  String get tileCarbonSub;

  /// No description provided for @tileWasteSub.
  ///
  /// In en, this message translates to:
  /// **'Find unusual electricity use'**
  String get tileWasteSub;

  /// No description provided for @tileSolarSub.
  ///
  /// In en, this message translates to:
  /// **'Rooftop solar estimate'**
  String get tileSolarSub;

  /// No description provided for @connOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Not connected to the server'**
  String get connOfflineTitle;

  /// No description provided for @connOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Bill reading, reports and solar need the server. Your saved data is safe on this phone.'**
  String get connOfflineBody;

  /// No description provided for @connOnline.
  ///
  /// In en, this message translates to:
  /// **'Server connected'**
  String get connOnline;

  /// No description provided for @connChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking connection…'**
  String get connChecking;

  /// No description provided for @connReadingOn.
  ///
  /// In en, this message translates to:
  /// **'Bill reading ready'**
  String get connReadingOn;

  /// No description provided for @uploadStepSend.
  ///
  /// In en, this message translates to:
  /// **'Sending the photo'**
  String get uploadStepSend;

  /// No description provided for @uploadStepRead.
  ///
  /// In en, this message translates to:
  /// **'AI is reading the bill'**
  String get uploadStepRead;

  /// No description provided for @uploadStepReview.
  ///
  /// In en, this message translates to:
  /// **'You check every value'**
  String get uploadStepReview;

  /// No description provided for @addBillTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for a good photo'**
  String get addBillTipsTitle;

  /// No description provided for @addBillTip1.
  ///
  /// In en, this message translates to:
  /// **'Lay the bill flat in good light'**
  String get addBillTip1;

  /// No description provided for @addBillTip2.
  ///
  /// In en, this message translates to:
  /// **'Fit the whole bill in the frame'**
  String get addBillTip2;

  /// No description provided for @addBillTip3.
  ///
  /// In en, this message translates to:
  /// **'Cover names, addresses and account numbers'**
  String get addBillTip3;

  /// No description provided for @addBillOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get addBillOr;

  /// No description provided for @billsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your energy bills in one place'**
  String get billsSubtitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your carbon footprint and electricity waste'**
  String get reportsSubtitle;

  /// No description provided for @solarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate rooftop solar for your factory'**
  String get solarSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, server, privacy and your data'**
  String get settingsSubtitle;

  /// No description provided for @solarHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get solarHowTitle;

  /// No description provided for @solarHow1.
  ///
  /// In en, this message translates to:
  /// **'Draw your roof on the map'**
  String get solarHow1;

  /// No description provided for @solarHow2.
  ///
  /// In en, this message translates to:
  /// **'Check the assumptions'**
  String get solarHow2;

  /// No description provided for @solarHow3.
  ///
  /// In en, this message translates to:
  /// **'See size, output and payback'**
  String get solarHow3;

  /// No description provided for @wasteAllGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get wasteAllGoodTitle;

  /// No description provided for @wasteAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get wasteAttentionTitle;

  /// No description provided for @carbonScopeSplit.
  ///
  /// In en, this message translates to:
  /// **'Scope 1 (fuel) vs Scope 2 (electricity)'**
  String get carbonScopeSplit;

  /// No description provided for @reviewAiRead.
  ///
  /// In en, this message translates to:
  /// **'Read by AI'**
  String get reviewAiRead;

  /// No description provided for @reviewManualBadge.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get reviewManualBadge;

  /// No description provided for @redactTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide private details'**
  String get redactTitle;

  /// No description provided for @redactHint.
  ///
  /// In en, this message translates to:
  /// **'Drag your finger over names, addresses, consumer and meter numbers. Each one is covered with a black box, and only the covered photo is sent.'**
  String get redactHint;

  /// No description provided for @redactKeepVisible.
  ///
  /// In en, this message translates to:
  /// **'Keep units, amounts and dates visible.'**
  String get redactKeepVisible;

  /// No description provided for @redactNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing private on the photo? Just continue.'**
  String get redactNothing;

  /// No description provided for @redactSend.
  ///
  /// In en, this message translates to:
  /// **'Read this bill'**
  String get redactSend;

  /// No description provided for @redactPreparing.
  ///
  /// In en, this message translates to:
  /// **'Covering the details…'**
  String get redactPreparing;

  /// No description provided for @redactAreas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No areas covered} =1{1 area covered} other{{count} areas covered}}'**
  String redactAreas(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
