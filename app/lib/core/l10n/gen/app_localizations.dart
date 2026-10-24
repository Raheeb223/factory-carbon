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
  /// **'BillToGreen'**
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

  /// No description provided for @connWakingTitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the server…'**
  String get connWakingTitle;

  /// No description provided for @connWakingBody.
  ///
  /// In en, this message translates to:
  /// **'The free server sleeps when nobody uses it and can take up to a minute to wake up. You can keep using the app meanwhile.'**
  String get connWakingBody;

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
  /// **'How do you count what you make?'**
  String get productionUnitLabel;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data and privacy'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'• Your factory profile, bills, production and reports are stored only on this phone.\n• When you scan a bill, the photo is sent to our server and to Google\'s Gemini API to read the values. Before sending, the phone hides printed names and addresses with black boxes; you check them and can cover more.\n• Our server does not store your photos or data. Google handles uploads under its Gemini API terms: if the server uses Google\'s free tier, Google may use uploads to improve its products and people at Google may review them.\n• Carbon, waste, solar and PDF calculations send the needed numbers to our server; nothing is stored there.'**
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
  /// **'The photo will be sent to our server and to Google\'s Gemini API to read the bill. Before sending, the phone hides printed names and addresses with black boxes, and you can cover anything else. Photos are not stored on our server. On Google\'s free tier, Google may use uploads to improve its products and people may review them.'**
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
  /// **'Unusual electricity use'**
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
  /// **'Cut the edges? (optional)'**
  String get cropTitle;

  /// No description provided for @cropReminder.
  ///
  /// In en, this message translates to:
  /// **'You do not need to cut out your name: names and addresses are hidden automatically in the next step. Cut only if the photo shows a lot of table or floor around the bill.'**
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
  /// **'How many {unit} did you make?'**
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
  /// **'Scope 1 (fuels burned on site)'**
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
  /// **'{value} t CO₂e'**
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
  /// **'Draft report (PDF)'**
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
  /// **'Scope 2 (location-based) = electricity kWh × Bangladesh grid emission factor. Scope 1 = fuel used × that fuel\'s factor (diesel litres, natural gas m³, LPG kg, furnace oil litres; DESNZ factors). Results are in tonnes CO2e. Intensity is shown only for complete months with production. These are estimates for planning and reporting to buyers, not a certified audit.'**
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
  /// **'Unusual electricity use'**
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
  /// **'Anomaly in {month}: about {pct}% more electricity than expected for the units produced; about {kwh} kWh{cost}. This is not proven waste: first check production, working hours and other causes.'**
  String wasteFlagMessage(String month, String pct, String kwh, String cost);

  /// No description provided for @wasteFlagMessageMad.
  ///
  /// In en, this message translates to:
  /// **'Anomaly in {month}: about {pct}% more electricity than a typical month; about {kwh} kWh{cost}. This is not proven waste: first check production, working hours and other causes.'**
  String wasteFlagMessageMad(String month, String pct, String kwh, String cost);

  /// No description provided for @wasteCostPart.
  ///
  /// In en, this message translates to:
  /// **', estimated extra cost about Tk {amount}'**
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
  /// **'Tap your factory roof and its outline is drawn for you. Drag the corners to fit it exactly, tap + on an edge to add a corner, long-press a corner to remove it.'**
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
  /// **'Solar details'**
  String get solarParamsTitle;

  /// No description provided for @paramUsableRoof.
  ///
  /// In en, this message translates to:
  /// **'Usable roof (%)'**
  String get paramUsableRoof;

  /// No description provided for @paramM2PerKwp.
  ///
  /// In en, this message translates to:
  /// **'Roof area per kW of panels (m²)'**
  String get paramM2PerKwp;

  /// No description provided for @paramPerformanceRatio.
  ///
  /// In en, this message translates to:
  /// **'System efficiency (%)'**
  String get paramPerformanceRatio;

  /// No description provided for @paramDegradation.
  ///
  /// In en, this message translates to:
  /// **'Panel ageing per year (%)'**
  String get paramDegradation;

  /// No description provided for @paramCapex.
  ///
  /// In en, this message translates to:
  /// **'Installer price per kW (Tk)'**
  String get paramCapex;

  /// No description provided for @paramOm.
  ///
  /// In en, this message translates to:
  /// **'Yearly maintenance (% of price)'**
  String get paramOm;

  /// No description provided for @paramPrice.
  ///
  /// In en, this message translates to:
  /// **'Your electricity price (Tk per kWh)'**
  String get paramPrice;

  /// No description provided for @paramPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Empty: average from your bills'**
  String get paramPriceHint;

  /// No description provided for @paramExportPrice.
  ///
  /// In en, this message translates to:
  /// **'Price the utility pays you (Tk per kWh)'**
  String get paramExportPrice;

  /// No description provided for @paramNetMetering.
  ///
  /// In en, this message translates to:
  /// **'Sell extra power to the grid (net metering)'**
  String get paramNetMetering;

  /// No description provided for @paramPsh.
  ///
  /// In en, this message translates to:
  /// **'Sunshine hours per day'**
  String get paramPsh;

  /// No description provided for @paramPshHint.
  ///
  /// In en, this message translates to:
  /// **'Empty: we use NASA satellite sunlight data for your roof.'**
  String get paramPshHint;

  /// No description provided for @paramDefault.
  ///
  /// In en, this message translates to:
  /// **'Typical {value}'**
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
  /// **'Money'**
  String get solarFinancials;

  /// No description provided for @solarCapex.
  ///
  /// In en, this message translates to:
  /// **'Installation cost'**
  String get solarCapex;

  /// No description provided for @solarYear1Savings.
  ///
  /// In en, this message translates to:
  /// **'Saved in year 1'**
  String get solarYear1Savings;

  /// No description provided for @solarYear1Om.
  ///
  /// In en, this message translates to:
  /// **'Maintenance in year 1'**
  String get solarYear1Om;

  /// No description provided for @solarPayback.
  ///
  /// In en, this message translates to:
  /// **'Pays back in'**
  String get solarPayback;

  /// No description provided for @solarNoPayback.
  ///
  /// In en, this message translates to:
  /// **'No payback'**
  String get solarNoPayback;

  /// No description provided for @solarNoFinancials.
  ///
  /// In en, this message translates to:
  /// **'Enter the installer\'s price per kW to see money saved and payback.'**
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
  /// **'Estimate only. Real savings depend on the installed system, its cost, the tariff, shading and how much solar power the factory uses. Roof strength and electrical design need a professional check.'**
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
  /// **'• Scope 1 and 2 from bills and fuel receipts: grid electricity, natural gas, diesel, LPG and furnace oil. No Scope 3, refrigerant leaks, coal or biomass.\n• The emissions report is a draft until its method and format are checked against your buyer\'s requirements.\n• Bill-reading accuracy has only been measured on a few sample bills. Always check values.\n• Names are hidden automatically only when printed in English letters. Cover handwritten or Bangla names by hand.\n• The unusual-use check flags statistical outliers against production; it cannot identify causes and does not prove waste.\n• Measured savings compare the whole factory before and after an action; weather, product mix or other changes can also play a part.\n• Solar results are estimates only.\n• Emission factors come from published government sources (shown with source and year in the report). Update them when newer editions appear and confirm they match the buyer\'s rules.\n• The app token is weak protection, adequate for a demo only.'**
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
  /// **'Check for unusual electricity use'**
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
  /// **'Take a photo of an electricity, gas, diesel, LPG or furnace oil bill. We read the numbers for you.'**
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
  /// **'Draft Scope 1 + 2 report and PDF'**
  String get tileCarbonSub;

  /// No description provided for @tileWasteSub.
  ///
  /// In en, this message translates to:
  /// **'Months that used more than expected for the output'**
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
  /// **'Names and addresses are hidden automatically'**
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
  /// **'Carbon footprint, unusual use and your savings'**
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
  /// **'Unusual months found'**
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
  /// **'Check the photo. To hide anything else (like the consumer or meter number), drag your finger over it. Tap a black box to remove it.'**
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

  /// No description provided for @productionUnitHelp.
  ///
  /// In en, this message translates to:
  /// **'Just tap one. You write how many you made each month later, on the Production page.'**
  String get productionUnitHelp;

  /// No description provided for @unitPieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get unitPieces;

  /// No description provided for @unitDozens.
  ///
  /// In en, this message translates to:
  /// **'dozens'**
  String get unitDozens;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get unitMeters;

  /// No description provided for @unitOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unitOther;

  /// No description provided for @unitOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Type your unit, e.g. sets'**
  String get unitOtherHint;

  /// No description provided for @cropYes.
  ///
  /// In en, this message translates to:
  /// **'Cut edges'**
  String get cropYes;

  /// No description provided for @cropSkip.
  ///
  /// In en, this message translates to:
  /// **'No, continue'**
  String get cropSkip;

  /// No description provided for @redactScanning.
  ///
  /// In en, this message translates to:
  /// **'Looking for names and addresses…'**
  String get redactScanning;

  /// No description provided for @redactAutoFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{✓ 1 name/address area hidden automatically} other{✓ {count} name/address areas hidden automatically}}'**
  String redactAutoFound(int count);

  /// No description provided for @redactAutoNone.
  ///
  /// In en, this message translates to:
  /// **'No printed names found. If you see a name, drag your finger over it.'**
  String get redactAutoNone;

  /// No description provided for @co2Kg.
  ///
  /// In en, this message translates to:
  /// **'= {kg} kg of CO₂ gas'**
  String co2Kg(String kg);

  /// No description provided for @co2Trees.
  ///
  /// In en, this message translates to:
  /// **'About {trees} trees would need a whole year to soak this up.'**
  String co2Trees(String trees);

  /// No description provided for @co2WhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What does this number mean?'**
  String get co2WhatTitle;

  /// No description provided for @co2WhatBody.
  ///
  /// In en, this message translates to:
  /// **'When your factory uses electricity, gas or diesel, carbon dioxide (CO₂) gas goes into the air. This gas makes the earth hotter. The number shows how much your factory caused.\n\n• t = tonne. 1 tonne = 1,000 kg.\n• CO₂e means \"CO₂ equivalent\": other warming gases are counted as the same amount of CO₂.\n• Scope 2 = from the grid electricity you buy. Power plants burn gas and oil to make it.\n• Scope 1 = from fuel your factory burns itself: diesel generator, gas boiler.\n\nHow it is calculated: units on the bill × emission factor. Example: 1,000 kWh × 0.62 kg per kWh = 620 kg = 0.62 t CO₂e.\n\nForeign buyers ask for this number. Lower is better: saving electricity or using solar brings it down.'**
  String get co2WhatBody;

  /// No description provided for @co2Explain.
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get co2Explain;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get tutorialTitle;

  /// No description provided for @tutorialListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get tutorialListen;

  /// No description provided for @tutorialStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get tutorialStop;

  /// No description provided for @tutorialNoVoice.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot speak this language yet. Install the voice in Settings › Text-to-speech.'**
  String get tutorialNoVoice;

  /// No description provided for @tutorialStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String tutorialStep(String n, String total);

  /// No description provided for @tut1Title.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the bill'**
  String get tut1Title;

  /// No description provided for @tut1Body.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Scan a bill\" on the home screen, then the camera. Use an electricity, gas, diesel, LPG or furnace oil bill.'**
  String get tut1Body;

  /// No description provided for @tut2Title.
  ///
  /// In en, this message translates to:
  /// **'Your name stays hidden'**
  String get tut2Title;

  /// No description provided for @tut2Body.
  ///
  /// In en, this message translates to:
  /// **'Black boxes cover names and addresses by themselves. Then tap \"Read this bill\".'**
  String get tut2Body;

  /// No description provided for @tut3Title.
  ///
  /// In en, this message translates to:
  /// **'Check the numbers'**
  String get tut3Title;

  /// No description provided for @tut3Body.
  ///
  /// In en, this message translates to:
  /// **'The app reads the units and the taka. If they match your bill, tick the box and tap Save.'**
  String get tut3Body;

  /// No description provided for @tut4Title.
  ///
  /// In en, this message translates to:
  /// **'Write how much you made'**
  String get tut4Title;

  /// No description provided for @tut4Body.
  ///
  /// In en, this message translates to:
  /// **'Every month, write how many pieces your factory made, on the Production page.'**
  String get tut4Body;

  /// No description provided for @tut5Title.
  ///
  /// In en, this message translates to:
  /// **'Get your carbon report'**
  String get tut5Title;

  /// No description provided for @tut5Body.
  ///
  /// In en, this message translates to:
  /// **'See how much pollution your factory makes, and send the PDF to your buyer.'**
  String get tut5Body;

  /// No description provided for @tut6Title.
  ///
  /// In en, this message translates to:
  /// **'Save money'**
  String get tut6Title;

  /// No description provided for @tut6Body.
  ///
  /// In en, this message translates to:
  /// **'A red warning means a month used more electricity than expected: check why. The Solar page shows how much solar panels can save.'**
  String get tut6Body;

  /// No description provided for @homeHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get homeHowTo;

  /// No description provided for @wastePerUnit.
  ///
  /// In en, this message translates to:
  /// **'kWh per unit produced: {actual} (expected {expected})'**
  String wastePerUnit(String actual, String expected);

  /// No description provided for @wasteBaseline.
  ///
  /// In en, this message translates to:
  /// **'Normal months: {value} kWh per unit produced'**
  String wasteBaseline(String value);

  /// No description provided for @wasteChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'What to check'**
  String get wasteChecksTitle;

  /// No description provided for @wasteChecksIntro.
  ///
  /// In en, this message translates to:
  /// **'Go through these in order. Add the fix to your action plan; the app then measures the saving from your next bills.'**
  String get wasteChecksIntro;

  /// No description provided for @paramRoofStructure.
  ///
  /// In en, this message translates to:
  /// **'Can the roof carry panels?'**
  String get paramRoofStructure;

  /// No description provided for @roofUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get roofUnknown;

  /// No description provided for @roofOk.
  ///
  /// In en, this message translates to:
  /// **'Engineer: yes'**
  String get roofOk;

  /// No description provided for @roofNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get roofNeedsWork;

  /// No description provided for @swShadingNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'Shading was not entered, so no shading loss is assumed. Shade from tanks, trees or buildings lowers generation.'**
  String get swShadingNotAssessed;

  /// No description provided for @swStructureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Roof strength is not checked yet. An engineer must confirm the roof can carry the panels.'**
  String get swStructureUnknown;

  /// No description provided for @swStructureNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'The roof needs structural work first; add that cost to the investment.'**
  String get swStructureNeedsWork;

  /// No description provided for @swTariffAverage.
  ///
  /// In en, this message translates to:
  /// **'Savings use your average bill price per kWh, which includes demand charge and VAT. Solar mainly cuts the energy charge, so real savings can be lower. Enter the energy charge rate for a closer estimate.'**
  String get swTariffAverage;

  /// No description provided for @tabCarbon.
  ///
  /// In en, this message translates to:
  /// **'Carbon'**
  String get tabCarbon;

  /// No description provided for @tabUnusual.
  ///
  /// In en, this message translates to:
  /// **'Unusual use'**
  String get tabUnusual;

  /// No description provided for @tabImpact.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get tabImpact;

  /// No description provided for @impactTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions and savings'**
  String get impactTitle;

  /// No description provided for @tileImpactSub.
  ///
  /// In en, this message translates to:
  /// **'Your action plan and measured savings'**
  String get tileImpactSub;

  /// No description provided for @impactIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick an action below, do it, then mark it done. The app compares your electricity per unit before and after, from your own bills, so you see real savings, not guesses.'**
  String get impactIntro;

  /// No description provided for @impactNothingDone.
  ///
  /// In en, this message translates to:
  /// **'When you finish an action, tap \"Mark as done\". Savings are measured from the next months\' bills.'**
  String get impactNothingDone;

  /// No description provided for @impactTooEarly.
  ///
  /// In en, this message translates to:
  /// **'Add the bills for the months after the action to see the result.'**
  String get impactTooEarly;

  /// No description provided for @impactNoBaseline.
  ///
  /// In en, this message translates to:
  /// **'At least 3 months of bills before the action are needed to compare.'**
  String get impactNoBaseline;

  /// No description provided for @impactNeedProduction.
  ///
  /// In en, this message translates to:
  /// **'Add monthly production so savings are measured fairly (more output may need more electricity).'**
  String get impactNeedProduction;

  /// No description provided for @impactSince.
  ///
  /// In en, this message translates to:
  /// **'Measured savings since {month}'**
  String impactSince(String month);

  /// No description provided for @impactTkSaved.
  ///
  /// In en, this message translates to:
  /// **'Tk {amount} saved'**
  String impactTkSaved(String amount);

  /// No description provided for @impactKwhSaved.
  ///
  /// In en, this message translates to:
  /// **'{kwh} kWh saved'**
  String impactKwhSaved(String kwh);

  /// No description provided for @impactKwhLine.
  ///
  /// In en, this message translates to:
  /// **'{kwh} kWh less electricity'**
  String impactKwhLine(String kwh);

  /// No description provided for @impactIntensityLine.
  ///
  /// In en, this message translates to:
  /// **'Electricity per unit produced: {pct} than before'**
  String impactIntensityLine(String pct);

  /// No description provided for @impactMeasuredMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Measured over 1 month} other{Measured over {count} months}}'**
  String impactMeasuredMonths(int count);

  /// No description provided for @impactEarly.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Early result: 1 month so far} other{Early result: {count} months so far}}'**
  String impactEarly(int count);

  /// No description provided for @impactCo2NeedsReport.
  ///
  /// In en, this message translates to:
  /// **'Update the carbon report to see the CO₂ saved.'**
  String get impactCo2NeedsReport;

  /// No description provided for @impactCaveat.
  ///
  /// In en, this message translates to:
  /// **'Production-adjusted, from your own bills. Weather, product mix or other changes can also play a part.'**
  String get impactCaveat;

  /// No description provided for @impactChartTitle.
  ///
  /// In en, this message translates to:
  /// **'kWh per unit produced, each month'**
  String get impactChartTitle;

  /// No description provided for @impactBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get impactBefore;

  /// No description provided for @impactAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get impactAfter;

  /// No description provided for @impactBaseline.
  ///
  /// In en, this message translates to:
  /// **'Average before'**
  String get impactBaseline;

  /// No description provided for @impactMethod.
  ///
  /// In en, this message translates to:
  /// **'Baseline = kWh per unit in up to 12 months before the first action. Saving each month = baseline × units produced − actual kWh. The action month is left out.'**
  String get impactMethod;

  /// No description provided for @impactCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Why it matters beyond the factory'**
  String get impactCommunityTitle;

  /// No description provided for @impactCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Less electricity means power plants burn less gas and oil: cleaner air for the families around the factory and more power left on the grid for homes and hospitals. Money saved can go to wages and safer workplaces.'**
  String get impactCommunityBody;

  /// No description provided for @actionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'My action plan'**
  String get actionPlanTitle;

  /// No description provided for @actionPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No actions yet. Add one from the suggestions below.'**
  String get actionPlanEmpty;

  /// No description provided for @actionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested actions'**
  String get actionSuggestions;

  /// No description provided for @actionAddToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get actionAddToPlan;

  /// No description provided for @actionAddOwn.
  ///
  /// In en, this message translates to:
  /// **'Own action'**
  String get actionAddOwn;

  /// No description provided for @actionAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your action plan'**
  String get actionAdded;

  /// No description provided for @actionAlreadyInPlan.
  ///
  /// In en, this message translates to:
  /// **'Already in your action plan'**
  String get actionAlreadyInPlan;

  /// No description provided for @actionPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get actionPlanned;

  /// No description provided for @actionDoneIn.
  ///
  /// In en, this message translates to:
  /// **'Done in {month}'**
  String actionDoneIn(String month);

  /// No description provided for @actionMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get actionMarkDone;

  /// No description provided for @actionUndoDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get actionUndoDone;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionCostTitle.
  ///
  /// In en, this message translates to:
  /// **'What did it cost? (optional)'**
  String get actionCostTitle;

  /// No description provided for @actionCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get actionCostLabel;

  /// No description provided for @actionCostHint.
  ///
  /// In en, this message translates to:
  /// **'Used to show when the action pays for itself.'**
  String get actionCostHint;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Your own action'**
  String get actionCustomTitle;

  /// No description provided for @actionCustomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Repair the dyeing machine motor'**
  String get actionCustomHint;

  /// No description provided for @actionResult.
  ///
  /// In en, this message translates to:
  /// **'kWh per unit produced: {pct} ({before} → {after})'**
  String actionResult(String pct, String before, String after);

  /// No description provided for @actionPayback.
  ///
  /// In en, this message translates to:
  /// **'Cost Tk {cost}: pays for itself in about {months} months'**
  String actionPayback(String cost, String months);

  /// No description provided for @actFixAirLeaks.
  ///
  /// In en, this message translates to:
  /// **'Fix compressed-air leaks'**
  String get actFixAirLeaks;

  /// No description provided for @actFixAirLeaksHow.
  ///
  /// In en, this message translates to:
  /// **'During a break, listen for hissing at hoses, couplings and air guns; tag and repair each leak.'**
  String get actFixAirLeaksHow;

  /// No description provided for @actSwitchOffIdle.
  ///
  /// In en, this message translates to:
  /// **'Switch off idle machines, lights and fans'**
  String get actSwitchOffIdle;

  /// No description provided for @actSwitchOffIdleHow.
  ///
  /// In en, this message translates to:
  /// **'Give one person per floor the job of switching off at lunch, after the last shift and on holidays.'**
  String get actSwitchOffIdleHow;

  /// No description provided for @actLowerAirPressure.
  ///
  /// In en, this message translates to:
  /// **'Lower the compressor pressure'**
  String get actLowerAirPressure;

  /// No description provided for @actLowerAirPressureHow.
  ///
  /// In en, this message translates to:
  /// **'Set the pressure to what the machines actually need; every extra bar costs electricity.'**
  String get actLowerAirPressureHow;

  /// No description provided for @actSteamLeaks.
  ///
  /// In en, this message translates to:
  /// **'Fix steam leaks and insulate pipes'**
  String get actSteamLeaks;

  /// No description provided for @actSteamLeaksHow.
  ///
  /// In en, this message translates to:
  /// **'Repair leaks and failed steam traps, insulate hot pipes and valves, return condensate to the boiler.'**
  String get actSteamLeaksHow;

  /// No description provided for @actGeneratorHours.
  ///
  /// In en, this message translates to:
  /// **'Run the generator only in power cuts'**
  String get actGeneratorHours;

  /// No description provided for @actGeneratorHoursHow.
  ///
  /// In en, this message translates to:
  /// **'Switch back to the grid as soon as power returns; keep a log of generator hours.'**
  String get actGeneratorHoursHow;

  /// No description provided for @actLedLighting.
  ///
  /// In en, this message translates to:
  /// **'Change to LED lights'**
  String get actLedLighting;

  /// No description provided for @actLedLightingHow.
  ///
  /// In en, this message translates to:
  /// **'Replace tube lights and bulbs with LED, starting with lights that are on the longest.'**
  String get actLedLightingHow;

  /// No description provided for @actServoMotors.
  ///
  /// In en, this message translates to:
  /// **'Fit servo motors on sewing machines'**
  String get actServoMotors;

  /// No description provided for @actServoMotorsHow.
  ///
  /// In en, this message translates to:
  /// **'Clutch motors run all the time; servo motors only run while sewing.'**
  String get actServoMotorsHow;

  /// No description provided for @actPowerFactor.
  ///
  /// In en, this message translates to:
  /// **'Fix the power factor'**
  String get actPowerFactor;

  /// No description provided for @actPowerFactorHow.
  ///
  /// In en, this message translates to:
  /// **'If the bill shows a power-factor penalty, have an electrician check or add a capacitor bank.'**
  String get actPowerFactorHow;

  /// No description provided for @actRooftopSolar.
  ///
  /// In en, this message translates to:
  /// **'Install rooftop solar'**
  String get actRooftopSolar;

  /// No description provided for @actRooftopSolarHow.
  ///
  /// In en, this message translates to:
  /// **'Use the Solar page for an estimate, then get quotes and an engineer\'s roof check.'**
  String get actRooftopSolarHow;

  /// No description provided for @inspConfirmCause.
  ///
  /// In en, this message translates to:
  /// **'Rule out normal reasons first'**
  String get inspConfirmCause;

  /// No description provided for @inspConfirmCauseHow.
  ///
  /// In en, this message translates to:
  /// **'Compare with production records, overtime and extra shifts, new machines, and hot weather (fans, AC).'**
  String get inspConfirmCauseHow;

  /// No description provided for @inspCompressedAir.
  ///
  /// In en, this message translates to:
  /// **'Compressors and air leaks'**
  String get inspCompressedAir;

  /// No description provided for @inspCompressedAirHow.
  ///
  /// In en, this message translates to:
  /// **'With machines stopped, listen for hissing at hoses and couplings. Check the compressor still loads and unloads, and is not set higher than needed.'**
  String get inspCompressedAirHow;

  /// No description provided for @inspIdleMachines.
  ///
  /// In en, this message translates to:
  /// **'Idle machines, lights and fans'**
  String get inspIdleMachines;

  /// No description provided for @inspIdleMachinesHow.
  ///
  /// In en, this message translates to:
  /// **'Walk the floor at lunch, after the last shift and on holidays. Note what is left on with nobody using it.'**
  String get inspIdleMachinesHow;

  /// No description provided for @inspBoilerSteam.
  ///
  /// In en, this message translates to:
  /// **'Boiler and steam'**
  String get inspBoilerSteam;

  /// No description provided for @inspBoilerSteamHow.
  ///
  /// In en, this message translates to:
  /// **'Look for steam leaks, failed steam traps and bare hot pipes; check condensate goes back to the boiler.'**
  String get inspBoilerSteamHow;

  /// No description provided for @inspGenerator.
  ///
  /// In en, this message translates to:
  /// **'Generator use'**
  String get inspGenerator;

  /// No description provided for @inspGeneratorHow.
  ///
  /// In en, this message translates to:
  /// **'Check the generator log for hours run while grid power was available, and late changeover back to the grid.'**
  String get inspGeneratorHow;

  /// No description provided for @factorGases.
  ///
  /// In en, this message translates to:
  /// **'Covers: {gases}'**
  String factorGases(String gases);

  /// No description provided for @draftReportNote.
  ///
  /// In en, this message translates to:
  /// **'Draft emissions report. It lists every bill and how it was entered, the reporting period, factors and sources. Check its method and format with your buyer before sending it as official.'**
  String get draftReportNote;

  /// No description provided for @actionPaybackUnderMonth.
  ///
  /// In en, this message translates to:
  /// **'Cost Tk {cost}: paid back in less than a month'**
  String actionPaybackUnderMonth(String cost);

  /// No description provided for @solarSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area, road or factory, or paste coordinates'**
  String get solarSearchHint;

  /// No description provided for @solarSearchNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Try an area name such as Tongi or Ashulia.'**
  String get solarSearchNone;

  /// No description provided for @solarSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search needs internet. Check the connection and try again.'**
  String get solarSearchFailed;

  /// No description provided for @solarGps.
  ///
  /// In en, this message translates to:
  /// **'My location (GPS)'**
  String get solarGps;

  /// No description provided for @solarGpsOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) in the phone settings.'**
  String get solarGpsOff;

  /// No description provided for @solarGpsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was not given.'**
  String get solarGpsDenied;

  /// No description provided for @solarGpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Try again near a window or outside.'**
  String get solarGpsFailed;

  /// No description provided for @solarZoomedIn.
  ///
  /// In en, this message translates to:
  /// **'Zoomed in. Now tap on your factory roof.'**
  String get solarZoomedIn;

  /// No description provided for @solarFindingRoof.
  ///
  /// In en, this message translates to:
  /// **'Finding the roof outline…'**
  String get solarFindingRoof;

  /// No description provided for @solarOutlineFound.
  ///
  /// In en, this message translates to:
  /// **'Roof outline found. Drag the corners if it needs adjusting, then tap Continue.'**
  String get solarOutlineFound;

  /// No description provided for @solarOutlineNone.
  ///
  /// In en, this message translates to:
  /// **'No building outline here on the map. Tap each corner of your roof instead.'**
  String get solarOutlineNone;

  /// No description provided for @solarOutlineOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not load building outlines. Tap each corner of your roof instead.'**
  String get solarOutlineOffline;

  /// No description provided for @solarOutlineAttribution.
  ///
  /// In en, this message translates to:
  /// **'Buildings © OpenStreetMap, Overture Maps'**
  String get solarOutlineAttribution;

  /// No description provided for @solarNoRoofThere.
  ///
  /// In en, this message translates to:
  /// **'No roof outline there. Drag the corners to adjust, or tap Clear to draw by hand.'**
  String get solarNoRoofThere;

  /// No description provided for @solarAdjustHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a corner to move it, tap + on an edge to add a corner, or long-press a corner to remove it.'**
  String get solarAdjustHint;

  /// No description provided for @solarOutlineSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to this roof. Undo goes back.'**
  String get solarOutlineSwitched;

  /// No description provided for @solarSuggested.
  ///
  /// In en, this message translates to:
  /// **'We marked the roof at your factory\'s location. Drag the corners to adjust, or tap another roof.'**
  String get solarSuggested;

  /// No description provided for @solarAreaApprox.
  ///
  /// In en, this message translates to:
  /// **'about {area} m²'**
  String solarAreaApprox(String area);

  /// No description provided for @paramsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every box is optional. Empty boxes use typical values, so you can press Estimate right away.'**
  String get paramsIntro;

  /// No description provided for @paramShadeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is anything shading the roof?'**
  String get paramShadeQuestion;

  /// No description provided for @paramShadeHint.
  ///
  /// In en, this message translates to:
  /// **'Water tanks, trees or taller buildings next to the factory.'**
  String get paramShadeHint;

  /// No description provided for @shadeNone.
  ///
  /// In en, this message translates to:
  /// **'No shade'**
  String get shadeNone;

  /// No description provided for @shadeSome.
  ///
  /// In en, this message translates to:
  /// **'Some (10%)'**
  String get shadeSome;

  /// No description provided for @shadeLot.
  ///
  /// In en, this message translates to:
  /// **'A lot (25%)'**
  String get shadeLot;

  /// No description provided for @paramRoofHint.
  ///
  /// In en, this message translates to:
  /// **'Panels add weight. Old or tin roofs need an engineer\'s check.'**
  String get paramRoofHint;

  /// No description provided for @paramCapexHint.
  ///
  /// In en, this message translates to:
  /// **'From a solar company\'s quote. Example: Tk 60 lakh for 100 kW = 60,000. Empty: you still see size and output, but no payback.'**
  String get paramCapexHint;

  /// No description provided for @paramNetMeteringHint.
  ///
  /// In en, this message translates to:
  /// **'Only if your utility (DPDC, DESCO, REB…) has approved it.'**
  String get paramNetMeteringHint;

  /// No description provided for @paramsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced (for engineers)'**
  String get paramsAdvanced;

  /// No description provided for @paramsAdvancedHint.
  ///
  /// In en, this message translates to:
  /// **'Leave these empty unless you have better values.'**
  String get paramsAdvancedHint;

  /// No description provided for @paramUsableRoofHint.
  ///
  /// In en, this message translates to:
  /// **'Part of the roof that can hold panels, after walkways, tanks and stairs.'**
  String get paramUsableRoofHint;

  /// No description provided for @paramM2PerKwpHint.
  ///
  /// In en, this message translates to:
  /// **'Space one kW of panels needs, including gaps.'**
  String get paramM2PerKwpHint;

  /// No description provided for @paramPerformanceRatioHint.
  ///
  /// In en, this message translates to:
  /// **'Power left after heat, dust, wiring and inverter losses.'**
  String get paramPerformanceRatioHint;

  /// No description provided for @paramDegradationHint.
  ///
  /// In en, this message translates to:
  /// **'Panels give a little less power every year.'**
  String get paramDegradationHint;

  /// No description provided for @paramOmHint.
  ///
  /// In en, this message translates to:
  /// **'Cleaning and repairs each year, as a share of the installation price. Often 1–2%.'**
  String get paramOmHint;

  /// No description provided for @invalidPercent.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 0 to 100'**
  String get invalidPercent;

  /// No description provided for @solarSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get solarSearching;

  /// No description provided for @solarGpsFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get solarGpsFinding;

  /// No description provided for @shadeUnsure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get shadeUnsure;

  /// Grid electricity only: the grid factor covers CO2, not other gases
  ///
  /// In en, this message translates to:
  /// **'{value} t CO₂'**
  String tonnesCo2(String value);

  /// No description provided for @solarPanelsFit.
  ///
  /// In en, this message translates to:
  /// **'Solar panels that fit on your roof'**
  String get solarPanelsFit;

  /// No description provided for @solarPanelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} panels'**
  String solarPanelsCount(String count);

  /// No description provided for @solarPanelsEach.
  ///
  /// In en, this message translates to:
  /// **'{watt} W each · {kw} kW system'**
  String solarPanelsEach(String watt, String kw);

  /// No description provided for @solarStatUnits.
  ///
  /// In en, this message translates to:
  /// **'units/month'**
  String get solarStatUnits;

  /// No description provided for @solarStatCovers.
  ///
  /// In en, this message translates to:
  /// **'of your use'**
  String get solarStatCovers;

  /// No description provided for @solarStatPayback.
  ///
  /// In en, this message translates to:
  /// **'payback'**
  String get solarStatPayback;

  /// No description provided for @solarSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'In simple words'**
  String get solarSummaryTitle;

  /// No description provided for @solarSay1.
  ///
  /// In en, this message translates to:
  /// **'Your roof has space for about {count} solar panels of {watt} W. Together they make a {kw} kW system.'**
  String solarSay1(String count, String watt, String kw);

  /// No description provided for @solarSay2.
  ///
  /// In en, this message translates to:
  /// **'They will make about {units} units (kWh) of electricity a month: more in sunny months, less in the monsoon.'**
  String solarSay2(String units);

  /// No description provided for @solarSay3.
  ///
  /// In en, this message translates to:
  /// **'Your factory uses about {use} units a month, so solar covers about {percent}% of it.'**
  String solarSay3(String use, String percent);

  /// No description provided for @solarSay4.
  ///
  /// In en, this message translates to:
  /// **'It saves about Tk {tk} a year. The installation cost of Tk {capex} comes back in about {years} years.'**
  String solarSay4(String tk, String capex, String years);

  /// No description provided for @solarSayNoPrice.
  ///
  /// In en, this message translates to:
  /// **'To see money saved and payback, go back and enter the installer\'s price per kW.'**
  String get solarSayNoPrice;

  /// No description provided for @solarSayNoBills.
  ///
  /// In en, this message translates to:
  /// **'Add your electricity bills to see how much of your use solar covers.'**
  String get solarSayNoBills;

  /// No description provided for @solarChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Units (kWh) made each month'**
  String get solarChartTitle;

  /// No description provided for @solarWorkedTitle.
  ///
  /// In en, this message translates to:
  /// **'How we worked it out'**
  String get solarWorkedTitle;

  /// No description provided for @solarWorkedHint.
  ///
  /// In en, this message translates to:
  /// **'Step by step, for engineers'**
  String get solarWorkedHint;

  /// No description provided for @solarStep1.
  ///
  /// In en, this message translates to:
  /// **'Roof area drawn on the map'**
  String get solarStep1;

  /// No description provided for @solarStep2.
  ///
  /// In en, this message translates to:
  /// **'Usable for panels: {percent}% of the roof (walkways, tanks and stairs kept free)'**
  String solarStep2(String percent);

  /// No description provided for @solarStep3.
  ///
  /// In en, this message translates to:
  /// **'System size: {area} m² ÷ {m2} m² per kW'**
  String solarStep3(String area, String m2);

  /// No description provided for @solarStep4.
  ///
  /// In en, this message translates to:
  /// **'Panels: {kw} kW ÷ {panelKw} kW per panel'**
  String solarStep4(String kw, String panelKw);

  /// No description provided for @solarStep5Nasa.
  ///
  /// In en, this message translates to:
  /// **'Full-sun hours per day, yearly average (NASA satellite data for this roof)'**
  String get solarStep5Nasa;

  /// No description provided for @solarStep5Manual.
  ///
  /// In en, this message translates to:
  /// **'Full-sun hours per day (your value)'**
  String get solarStep5Manual;

  /// No description provided for @solarStep6.
  ///
  /// In en, this message translates to:
  /// **'Yearly output: {kw} kW × {hours} h × 365 days × {pr}% efficiency{shade}'**
  String solarStep6(String kw, String hours, String pr, String shade);

  /// No description provided for @solarStepShade.
  ///
  /// In en, this message translates to:
  /// **' × {percent}% left after shade'**
  String solarStepShade(String percent);

  /// No description provided for @solarStep7.
  ///
  /// In en, this message translates to:
  /// **'CO₂ avoided: {units} kWh of grid power replaced × {factor} kg per kWh'**
  String solarStep7(String units, String factor);

  /// No description provided for @solarStepNote.
  ///
  /// In en, this message translates to:
  /// **'kWp = panel power in full sun (1,000 W/m²). One full-sun hour = 1 kWh of sunlight per m². Efficiency covers heat, dust, wiring and inverter losses.'**
  String get solarStepNote;

  /// No description provided for @valueHoursDay.
  ///
  /// In en, this message translates to:
  /// **'{value} h/day'**
  String valueHoursDay(String value);

  /// No description provided for @valueWatt.
  ///
  /// In en, this message translates to:
  /// **'{value} W'**
  String valueWatt(String value);

  /// No description provided for @paramPanelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Panel size (watts per panel)'**
  String get paramPanelQuestion;

  /// No description provided for @paramPanelHint.
  ///
  /// In en, this message translates to:
  /// **'Written on the panel label or the installer\'s quote. Most new panels are 540–600 W. Not sure? Keep 550 W.'**
  String get paramPanelHint;

  /// No description provided for @carbonPlainTitle.
  ///
  /// In en, this message translates to:
  /// **'In simple words'**
  String get carbonPlainTitle;

  /// No description provided for @carbonSay1.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end}, your factory released {total} tonnes of CO₂, about {perMonth} tonnes a month.'**
  String carbonSay1(String start, String end, String total, String perMonth);

  /// No description provided for @carbonSay2.
  ///
  /// In en, this message translates to:
  /// **'{source} causes the most: {pct}% of the total.'**
  String carbonSay2(String source, String pct);

  /// No description provided for @carbonSay3.
  ///
  /// In en, this message translates to:
  /// **'For every 1,000 {unit} you make, about {t} tonnes of CO₂ is released.'**
  String carbonSay3(String unit, String t);

  /// No description provided for @carbonSay4.
  ///
  /// In en, this message translates to:
  /// **'Highest month: {month}, with {t} tonnes.'**
  String carbonSay4(String month, String t);

  /// No description provided for @carbonCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'How it was calculated'**
  String get carbonCalcTitle;

  /// No description provided for @carbonCalcHint.
  ///
  /// In en, this message translates to:
  /// **'Units on your bills × emission factor = CO₂'**
  String get carbonCalcHint;

  /// No description provided for @carbonCalcLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} {unit} × {factor} kg per {per}'**
  String carbonCalcLine(String amount, String unit, String factor, String per);

  /// No description provided for @carbonCalcResult.
  ///
  /// In en, this message translates to:
  /// **'= {t} t'**
  String carbonCalcResult(String t);

  /// No description provided for @carbonCalcTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get carbonCalcTotal;

  /// No description provided for @carbonCalcNote.
  ///
  /// In en, this message translates to:
  /// **'1 tonne (t) = 1,000 kg. The factors and their sources are listed further down.'**
  String get carbonCalcNote;

  /// No description provided for @carbonUnitKwh.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get carbonUnitKwh;

  /// No description provided for @carbonUnitLitre.
  ///
  /// In en, this message translates to:
  /// **'litres'**
  String get carbonUnitLitre;

  /// No description provided for @carbonUnitLitreOne.
  ///
  /// In en, this message translates to:
  /// **'litre'**
  String get carbonUnitLitreOne;

  /// No description provided for @carbonUnitM3.
  ///
  /// In en, this message translates to:
  /// **'m³'**
  String get carbonUnitM3;

  /// No description provided for @carbonCutTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to start'**
  String get carbonCutTitle;

  /// No description provided for @carbonCutTk.
  ///
  /// In en, this message translates to:
  /// **'Using 10% less electricity would save about {kwh} kWh, Tk {tk} and {t} tonnes of CO₂ a year.'**
  String carbonCutTk(String kwh, String tk, String t);

  /// No description provided for @carbonCutNoTk.
  ///
  /// In en, this message translates to:
  /// **'Using 10% less electricity would save about {kwh} kWh and {t} tonnes of CO₂ a year.'**
  String carbonCutNoTk(String kwh, String t);

  /// No description provided for @carbonCutButton.
  ///
  /// In en, this message translates to:
  /// **'See what to do'**
  String get carbonCutButton;

  /// No description provided for @actionBestForYou.
  ///
  /// In en, this message translates to:
  /// **'Best for you'**
  String get actionBestForYou;

  /// No description provided for @actionBestWhy.
  ///
  /// In en, this message translates to:
  /// **'{source} is {pct}% of your CO₂, so this helps most.'**
  String actionBestWhy(String source, String pct);

  /// No description provided for @actionCostFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get actionCostFree;

  /// No description provided for @actionCostLow.
  ///
  /// In en, this message translates to:
  /// **'Low cost'**
  String get actionCostLow;

  /// No description provided for @actionCostMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium cost'**
  String get actionCostMedium;

  /// No description provided for @actionCostHigh.
  ///
  /// In en, this message translates to:
  /// **'Big investment'**
  String get actionCostHigh;

  /// No description provided for @actionCutsElectricity.
  ///
  /// In en, this message translates to:
  /// **'Cuts electricity'**
  String get actionCutsElectricity;

  /// No description provided for @actionCutsDiesel.
  ///
  /// In en, this message translates to:
  /// **'Cuts diesel'**
  String get actionCutsDiesel;

  /// No description provided for @actionCutsGas.
  ///
  /// In en, this message translates to:
  /// **'Cuts gas'**
  String get actionCutsGas;

  /// No description provided for @actionHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get actionHowTo;

  /// No description provided for @actionSuggestionsHint.
  ///
  /// In en, this message translates to:
  /// **'Start with the ones marked “Best for you”. Tap a card to see the steps.'**
  String get actionSuggestionsHint;

  /// No description provided for @actFixAirLeaksSteps.
  ///
  /// In en, this message translates to:
  /// **'With machines stopped (lunch or a holiday), walk the floor and listen for hissing at hoses, couplings and air guns.\nTie a tag on each leak and write it on a list.\nRepair or replace the parts, then check again every month.'**
  String get actFixAirLeaksSteps;

  /// No description provided for @actSwitchOffIdleSteps.
  ///
  /// In en, this message translates to:
  /// **'Choose one person on each floor to be in charge of switching off.\nSwitch off machines, lights and fans at lunch, after the last shift and on holidays.\nPut a simple checklist on the wall and sign it every day.'**
  String get actSwitchOffIdleSteps;

  /// No description provided for @actLowerAirPressureSteps.
  ///
  /// In en, this message translates to:
  /// **'Ask the machine suppliers what air pressure each machine really needs.\nLower the compressor setting a little at a time while production keeps running.\nStop at the lowest setting where every machine still works well.'**
  String get actLowerAirPressureSteps;

  /// No description provided for @actSteamLeaksSteps.
  ///
  /// In en, this message translates to:
  /// **'Walk the steam lines and mark leaks and steam traps that blow steam all the time.\nRepair them and insulate bare hot pipes and valves.\nSend hot condensate water back to the boiler.'**
  String get actSteamLeaksSteps;

  /// No description provided for @actGeneratorHoursSteps.
  ///
  /// In en, this message translates to:
  /// **'Keep a log book of when the generator starts and stops.\nSwitch back to grid power as soon as it returns.\nEach week, compare the log with the power-cut times.'**
  String get actGeneratorHoursSteps;

  /// No description provided for @actLedLightingSteps.
  ///
  /// In en, this message translates to:
  /// **'Find the lights that are on the longest (production floor, 2–3 shifts).\nReplace those tube lights and bulbs with LED first.\nChange the rest when the old ones fail.'**
  String get actLedLightingSteps;

  /// No description provided for @actServoMotorsSteps.
  ///
  /// In en, this message translates to:
  /// **'Count the sewing machines that still have clutch motors (they hum even when nobody sews).\nAsk a supplier for a price to fit servo motors.\nStart with one line, compare its electricity, then do the rest.'**
  String get actServoMotorsSteps;

  /// No description provided for @actPowerFactorSteps.
  ///
  /// In en, this message translates to:
  /// **'Look on the electricity bill for a power-factor (PF) penalty or a low PF value.\nAsk a licensed electrician to check the capacitor bank.\nRepair or add capacitors until the penalty is gone from the bill.'**
  String get actPowerFactorSteps;

  /// No description provided for @actRooftopSolarSteps.
  ///
  /// In en, this message translates to:
  /// **'Open the Solar page and tap your roof for a free estimate.\nGet quotes from 2–3 solar companies.\nAsk an engineer to check that the roof can carry the panels.'**
  String get actRooftopSolarSteps;

  /// No description provided for @scope1Short.
  ///
  /// In en, this message translates to:
  /// **'Scope 1'**
  String get scope1Short;

  /// No description provided for @scope2Short.
  ///
  /// In en, this message translates to:
  /// **'Scope 2'**
  String get scope2Short;

  /// No description provided for @actionTapForSteps.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to see the steps.'**
  String get actionTapForSteps;

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'Already on the phone from a bill or typed in, so these are not imported: {list}.'**
  String importSkipped(String list);

  /// No description provided for @importReplaced.
  ///
  /// In en, this message translates to:
  /// **'These replace values imported earlier: {list}.'**
  String importReplaced(String list);

  /// No description provided for @importNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Everything in this file is already on the phone. There is nothing new to import.'**
  String get importNothingNew;

  /// No description provided for @backupGroup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupGroup;

  /// No description provided for @backupSave.
  ///
  /// In en, this message translates to:
  /// **'Save a backup'**
  String get backupSave;

  /// No description provided for @backupSaveHint.
  ///
  /// In en, this message translates to:
  /// **'One file with your factory, bills, production, actions and solar plans. Bill photos are not included. Keep it safe, e.g. in Google Drive.'**
  String get backupSaveHint;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupRestore;

  /// No description provided for @backupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Use this on a new phone or after deleting the app.'**
  String get backupRestoreHint;

  /// No description provided for @backupNotABackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a BillToGreen backup.'**
  String get backupNotABackup;

  /// No description provided for @backupNewer.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of the app. Update the app first.'**
  String get backupNewer;

  /// No description provided for @backupDamaged.
  ///
  /// In en, this message translates to:
  /// **'This backup file is damaged and cannot be restored.'**
  String get backupDamaged;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data on this phone?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The backup from {date} ({factory}) has {bills} bills covering {months} months, {actions} actions and {plans} solar plans. Everything now on this phone will be replaced.'**
  String backupRestoreConfirmBody(
    String date,
    String factory,
    int bills,
    int months,
    int actions,
    int plans,
  );

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @gapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing months'**
  String get gapsTitle;

  /// No description provided for @gapsHint.
  ///
  /// In en, this message translates to:
  /// **'Reports and the electricity check are only complete when every month is entered.'**
  String get gapsHint;

  /// No description provided for @gapsElectricity.
  ///
  /// In en, this message translates to:
  /// **'No electricity bill: {months}'**
  String gapsElectricity(String months);

  /// No description provided for @gapsProduction.
  ///
  /// In en, this message translates to:
  /// **'No production figure: {months}'**
  String gapsProduction(String months);

  /// No description provided for @gapsMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String gapsMore(int count);

  /// No description provided for @gapsAddBill.
  ///
  /// In en, this message translates to:
  /// **'Add bill'**
  String get gapsAddBill;

  /// No description provided for @gapsAddProduction.
  ///
  /// In en, this message translates to:
  /// **'Add production'**
  String get gapsAddProduction;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get periodLabel;

  /// No description provided for @periodHint.
  ///
  /// In en, this message translates to:
  /// **'Buyers usually ask for one year. Bangladesh\'s fiscal year runs from July to June.'**
  String get periodHint;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All data'**
  String get periodAll;

  /// No description provided for @periodCalendar.
  ///
  /// In en, this message translates to:
  /// **'{year} (January–December)'**
  String periodCalendar(String year);

  /// No description provided for @periodFiscal.
  ///
  /// In en, this message translates to:
  /// **'Fiscal year {label} (July–June)'**
  String periodFiscal(String label);

  /// No description provided for @periodSoFar.
  ///
  /// In en, this message translates to:
  /// **'year so far'**
  String get periodSoFar;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with a year earlier'**
  String get compareTitle;

  /// No description provided for @compareWith.
  ///
  /// In en, this message translates to:
  /// **'Same months one year earlier: {start} – {end}'**
  String compareWith(String start, String end);

  /// No description provided for @compareDown.
  ///
  /// In en, this message translates to:
  /// **'{pct}% lower'**
  String compareDown(String pct);

  /// No description provided for @compareUp.
  ///
  /// In en, this message translates to:
  /// **'{pct}% higher'**
  String compareUp(String pct);

  /// No description provided for @compareSame.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get compareSame;

  /// No description provided for @compareNote.
  ///
  /// In en, this message translates to:
  /// **'Lower CO₂ per 1,000 {unit} means the factory is becoming more efficient, even if it made more.'**
  String compareNote(String unit);

  /// No description provided for @compareGaps.
  ///
  /// In en, this message translates to:
  /// **'Some months have no data in one of the two periods, so this comparison is less reliable.'**
  String get compareGaps;

  /// No description provided for @billTypeLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get billTypeLpg;

  /// No description provided for @billTypeFurnaceOil.
  ///
  /// In en, this message translates to:
  /// **'Furnace oil'**
  String get billTypeFurnaceOil;

  /// No description provided for @factorLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get factorLpg;

  /// No description provided for @factorFurnaceOil.
  ///
  /// In en, this message translates to:
  /// **'Furnace oil'**
  String get factorFurnaceOil;

  /// No description provided for @legendLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get legendLpg;

  /// No description provided for @legendFurnaceOil.
  ///
  /// In en, this message translates to:
  /// **'Furnace oil'**
  String get legendFurnaceOil;

  /// No description provided for @importColLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG kg'**
  String get importColLpg;

  /// No description provided for @importColFurnaceOil.
  ///
  /// In en, this message translates to:
  /// **'Furnace oil L'**
  String get importColFurnaceOil;

  /// No description provided for @carbonUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get carbonUnitKg;

  /// No description provided for @actionCutsBoilerFuel.
  ///
  /// In en, this message translates to:
  /// **'Cuts boiler fuel'**
  String get actionCutsBoilerFuel;

  /// No description provided for @setupStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String setupStep(int n, int total);

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @setupBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your factory'**
  String get setupBasicsTitle;

  /// No description provided for @setupBasicsSub.
  ///
  /// In en, this message translates to:
  /// **'The name and type appear on your reports to buyers.'**
  String get setupBasicsSub;

  /// No description provided for @facilityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Main product or process'**
  String get facilityTypeLabel;

  /// No description provided for @facilityKnit.
  ///
  /// In en, this message translates to:
  /// **'Knit'**
  String get facilityKnit;

  /// No description provided for @facilityWoven.
  ///
  /// In en, this message translates to:
  /// **'Woven'**
  String get facilityWoven;

  /// No description provided for @facilitySweater.
  ///
  /// In en, this message translates to:
  /// **'Sweater'**
  String get facilitySweater;

  /// No description provided for @facilityDenim.
  ///
  /// In en, this message translates to:
  /// **'Denim'**
  String get facilityDenim;

  /// No description provided for @facilityDyeing.
  ///
  /// In en, this message translates to:
  /// **'Dyeing & finishing'**
  String get facilityDyeing;

  /// No description provided for @facilityWashing.
  ///
  /// In en, this message translates to:
  /// **'Washing'**
  String get facilityWashing;

  /// No description provided for @facilityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get facilityOther;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @districtDhaka.
  ///
  /// In en, this message translates to:
  /// **'Dhaka'**
  String get districtDhaka;

  /// No description provided for @districtGazipur.
  ///
  /// In en, this message translates to:
  /// **'Gazipur'**
  String get districtGazipur;

  /// No description provided for @districtNarayanganj.
  ///
  /// In en, this message translates to:
  /// **'Narayanganj'**
  String get districtNarayanganj;

  /// No description provided for @districtNarsingdi.
  ///
  /// In en, this message translates to:
  /// **'Narsingdi'**
  String get districtNarsingdi;

  /// No description provided for @districtChattogram.
  ///
  /// In en, this message translates to:
  /// **'Chattogram'**
  String get districtChattogram;

  /// No description provided for @districtMymensingh.
  ///
  /// In en, this message translates to:
  /// **'Mymensingh'**
  String get districtMymensingh;

  /// No description provided for @districtCumilla.
  ///
  /// In en, this message translates to:
  /// **'Cumilla'**
  String get districtCumilla;

  /// No description provided for @districtKhulna.
  ///
  /// In en, this message translates to:
  /// **'Khulna'**
  String get districtKhulna;

  /// No description provided for @districtOther.
  ///
  /// In en, this message translates to:
  /// **'Other district'**
  String get districtOther;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address or area (optional)'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Konabari, Kashimpur'**
  String get addressHint;

  /// No description provided for @setupLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory location'**
  String get setupLocationTitle;

  /// No description provided for @setupLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Used for the sunlight data in the solar estimate and to open the map at your roof. You can skip this and add it later.'**
  String get setupLocationSub;

  /// No description provided for @locGps.
  ///
  /// In en, this message translates to:
  /// **'I am at the factory: use my location'**
  String get locGps;

  /// No description provided for @locGpsBusy.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locGpsBusy;

  /// No description provided for @locPasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Or paste a Google Maps link or coordinates'**
  String get locPasteLabel;

  /// No description provided for @locPasteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 23.9995, 90.4203'**
  String get locPasteHint;

  /// No description provided for @locPasteInvalid.
  ///
  /// In en, this message translates to:
  /// **'No coordinates found. In Google Maps, hold your finger on the factory and copy the numbers shown, or type latitude, longitude.'**
  String get locPasteInvalid;

  /// No description provided for @locSet.
  ///
  /// In en, this message translates to:
  /// **'Location set: {lat}, {lon}'**
  String locSet(String lat, String lon);

  /// No description provided for @locNotSet.
  ///
  /// In en, this message translates to:
  /// **'No location yet'**
  String get locNotSet;

  /// No description provided for @locOutside.
  ///
  /// In en, this message translates to:
  /// **'This point is outside Bangladesh. Check the numbers: latitude is about 20.5–26.7 and longitude about 88–92.7.'**
  String get locOutside;

  /// No description provided for @locBothNeeded.
  ///
  /// In en, this message translates to:
  /// **'Enter both latitude and longitude, or clear them.'**
  String get locBothNeeded;

  /// No description provided for @locManual.
  ///
  /// In en, this message translates to:
  /// **'Type latitude and longitude'**
  String get locManual;

  /// No description provided for @setupSkipLocation.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get setupSkipLocation;

  /// No description provided for @setupProductionTitle.
  ///
  /// In en, this message translates to:
  /// **'Production and energy'**
  String get setupProductionTitle;

  /// No description provided for @setupProductionSub.
  ///
  /// In en, this message translates to:
  /// **'This makes CO₂ per unit, reminders and suggestions fit your factory.'**
  String get setupProductionSub;

  /// No description provided for @workersLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of workers (optional)'**
  String get workersLabel;

  /// No description provided for @shiftsLabel.
  ///
  /// In en, this message translates to:
  /// **'Shifts per day'**
  String get shiftsLabel;

  /// No description provided for @energySourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Energy the factory uses'**
  String get energySourcesLabel;

  /// No description provided for @energySourcesHint.
  ///
  /// In en, this message translates to:
  /// **'Tick everything that applies. You can change this later in Settings.'**
  String get energySourcesHint;

  /// No description provided for @sourcesNeedOne.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one energy source.'**
  String get sourcesNeedOne;

  /// No description provided for @sourceElectricity.
  ///
  /// In en, this message translates to:
  /// **'Grid electricity'**
  String get sourceElectricity;

  /// No description provided for @sourceGas.
  ///
  /// In en, this message translates to:
  /// **'Natural gas'**
  String get sourceGas;

  /// No description provided for @sourceDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel generator'**
  String get sourceDiesel;

  /// No description provided for @sourceLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get sourceLpg;

  /// No description provided for @sourceFurnaceOil.
  ///
  /// In en, this message translates to:
  /// **'Furnace oil'**
  String get sourceFurnaceOil;

  /// No description provided for @sourceSolar.
  ///
  /// In en, this message translates to:
  /// **'Rooftop solar (installed)'**
  String get sourceSolar;

  /// No description provided for @reportingYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Reporting year'**
  String get reportingYearLabel;

  /// No description provided for @reportingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Jan–Dec'**
  String get reportingCalendar;

  /// No description provided for @reportingFiscal.
  ///
  /// In en, this message translates to:
  /// **'Jul–Jun (fiscal)'**
  String get reportingFiscal;

  /// No description provided for @reportingYearHint.
  ///
  /// In en, this message translates to:
  /// **'Most buyers and the Higg FEM use January–December. Reports open on this year.'**
  String get reportingYearHint;

  /// No description provided for @setupReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your details'**
  String get setupReviewTitle;

  /// No description provided for @setupReviewSub.
  ///
  /// In en, this message translates to:
  /// **'Go back to change anything. Then read the privacy notice and start.'**
  String get setupReviewSub;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share summary (WhatsApp)'**
  String get shareSummary;

  /// No description provided for @shareSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'A short message for the owner or management, in plain words.'**
  String get shareSummaryHint;

  /// No description provided for @shareHeading.
  ///
  /// In en, this message translates to:
  /// **'CO₂ report from our utility bills'**
  String get shareHeading;

  /// No description provided for @shareCompare.
  ///
  /// In en, this message translates to:
  /// **'That is {change} than {start} – {end}.'**
  String shareCompare(String change, String start, String end);

  /// No description provided for @shareCost.
  ///
  /// In en, this message translates to:
  /// **'Electricity bills in this period: Tk {tk}.'**
  String shareCost(String tk);

  /// No description provided for @shareFooter.
  ///
  /// In en, this message translates to:
  /// **'Draft figures from bills checked by the factory. Made with BillToGreen.'**
  String get shareFooter;

  /// No description provided for @targetSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a CO₂ reduction target'**
  String get targetSetTitle;

  /// No description provided for @targetSetBody.
  ///
  /// In en, this message translates to:
  /// **'Buyers increasingly ask suppliers for a target and yearly progress. A science-based pace is at least {pct}% less CO₂ each year.'**
  String targetSetBody(String pct);

  /// No description provided for @targetSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set a target'**
  String get targetSetButton;

  /// No description provided for @targetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your CO₂ target'**
  String get targetTitle;

  /// No description provided for @targetEdit.
  ///
  /// In en, this message translates to:
  /// **'Change target'**
  String get targetEdit;

  /// No description provided for @targetLine.
  ///
  /// In en, this message translates to:
  /// **'{pct}% less {metric} by {year}, compared with {baseline}.'**
  String targetLine(String pct, String metric, String year, String baseline);

  /// No description provided for @targetMetricPerUnit.
  ///
  /// In en, this message translates to:
  /// **'CO₂ per 1,000 {unit}'**
  String targetMetricPerUnit(String unit);

  /// No description provided for @targetMetricTotal.
  ///
  /// In en, this message translates to:
  /// **'total CO₂'**
  String get targetMetricTotal;

  /// No description provided for @targetPerUnitShort.
  ///
  /// In en, this message translates to:
  /// **'Per 1,000 {unit}'**
  String targetPerUnitShort(String unit);

  /// No description provided for @targetTotalShort.
  ///
  /// In en, this message translates to:
  /// **'Total CO₂'**
  String get targetTotalShort;

  /// No description provided for @targetOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get targetOnTrack;

  /// No description provided for @targetBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get targetBehind;

  /// No description provided for @targetNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get targetNoData;

  /// No description provided for @targetNow.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months: {change} than the baseline year.'**
  String targetNow(String change);

  /// No description provided for @targetNeeded.
  ///
  /// In en, this message translates to:
  /// **'To stay on track: {pct}% less by now.'**
  String targetNeeded(String pct);

  /// No description provided for @targetNoDataHint.
  ///
  /// In en, this message translates to:
  /// **'Add bills for all of {year} and for the latest 12 months to see progress.'**
  String targetNoDataHint(String year);

  /// No description provided for @targetSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'CO₂ reduction target'**
  String get targetSheetTitle;

  /// No description provided for @targetWhat.
  ///
  /// In en, this message translates to:
  /// **'What do you want to reduce?'**
  String get targetWhat;

  /// No description provided for @targetPerUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Fair to a growing factory: making more {unit} does not count against you.'**
  String targetPerUnitHint(String unit);

  /// No description provided for @targetBaseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline year'**
  String get targetBaseline;

  /// No description provided for @targetBy.
  ///
  /// In en, this message translates to:
  /// **'Target year'**
  String get targetBy;

  /// No description provided for @targetHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much less?'**
  String get targetHowMuch;

  /// No description provided for @targetSbtiChip.
  ///
  /// In en, this message translates to:
  /// **'{pct}% (science-based)'**
  String targetSbtiChip(String pct);

  /// No description provided for @targetPctLabel.
  ///
  /// In en, this message translates to:
  /// **'Reduction'**
  String get targetPctLabel;

  /// No description provided for @targetSbtiHint.
  ///
  /// In en, this message translates to:
  /// **'Science-based targets need at least {rate}% less a year: {pct}% for these years.'**
  String targetSbtiHint(String rate, String pct);

  /// No description provided for @targetRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove target'**
  String get targetRemove;

  /// No description provided for @energyTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy used'**
  String get energyTitle;

  /// No description provided for @energyTotal.
  ///
  /// In en, this message translates to:
  /// **'{mwh} MWh · {gj} GJ'**
  String energyTotal(String mwh, String gj);

  /// No description provided for @energyNote.
  ///
  /// In en, this message translates to:
  /// **'Buyer questionnaires such as the Higg FEM ask for these numbers. Fuels are counted at their net heating value; the PDF lists the conversion values and sources.'**
  String get energyNote;

  /// No description provided for @energyIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Some fuels could not be converted to kWh, so no total is shown.'**
  String get energyIncomplete;

  /// No description provided for @homeMonthsWithData.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} months have data'**
  String homeMonthsWithData(int n, int total);

  /// No description provided for @targetNowSame.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months: about the same as the baseline year.'**
  String get targetNowSame;

  /// No description provided for @passportTitle.
  ///
  /// In en, this message translates to:
  /// **'Carbon Passport'**
  String get passportTitle;

  /// No description provided for @passportBannerSub.
  ///
  /// In en, this message translates to:
  /// **'A QR code your buyers can scan to see your signed carbon summary.'**
  String get passportBannerSub;

  /// No description provided for @passportWhy.
  ///
  /// In en, this message translates to:
  /// **'Big brands ask their suppliers for emissions data. Show this QR code to prove yours — it opens on any phone, no app needed.'**
  String get passportWhy;

  /// No description provided for @passportScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan with any phone camera'**
  String get passportScanHint;

  /// No description provided for @passportShare.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get passportShare;

  /// No description provided for @passportCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get passportCopy;

  /// No description provided for @passportCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get passportCopied;

  /// No description provided for @passportRefresh.
  ///
  /// In en, this message translates to:
  /// **'Make a new one'**
  String get passportRefresh;

  /// No description provided for @passportIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued {date} · signed by the BillToGreen server'**
  String passportIssued(String date);

  /// No description provided for @passportNeedsData.
  ///
  /// In en, this message translates to:
  /// **'Add at least one bill to create your Carbon Passport.'**
  String get passportNeedsData;

  /// No description provided for @passportMaking.
  ///
  /// In en, this message translates to:
  /// **'Creating your Carbon Passport…'**
  String get passportMaking;

  /// No description provided for @homeSolarSaves.
  ///
  /// In en, this message translates to:
  /// **'Solar could save Tk {amount} a year'**
  String homeSolarSaves(String amount);

  /// No description provided for @homeSolarSavesSub.
  ///
  /// In en, this message translates to:
  /// **'{kwp} kWp on your roof · {co2} t CO₂e less each year'**
  String homeSolarSavesSub(String kwp, String co2);

  /// No description provided for @homeSolarTry.
  ///
  /// In en, this message translates to:
  /// **'How much could solar save you?'**
  String get homeSolarTry;

  /// No description provided for @homeSolarTrySub.
  ///
  /// In en, this message translates to:
  /// **'Draw your roof on the map to see the savings and payback time.'**
  String get homeSolarTrySub;

  /// No description provided for @loanTitle.
  ///
  /// In en, this message translates to:
  /// **'Green Loan Ready'**
  String get loanTitle;

  /// No description provided for @loanBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Can solar pay its own loan? Check it, then send your bank a summary.'**
  String get loanBannerSub;

  /// No description provided for @loanOpen.
  ///
  /// In en, this message translates to:
  /// **'Can solar pay its own loan?'**
  String get loanOpen;

  /// No description provided for @loanPaysItself.
  ///
  /// In en, this message translates to:
  /// **'Solar pays its own loan'**
  String get loanPaysItself;

  /// No description provided for @loanCovers.
  ///
  /// In en, this message translates to:
  /// **'Savings cover {pct}% of the loan payment'**
  String loanCovers(String pct);

  /// No description provided for @loanVs.
  ///
  /// In en, this message translates to:
  /// **'Tk {save} saved a month vs Tk {emi} loan payment a month'**
  String loanVs(String save, String emi);

  /// No description provided for @loanStatSave.
  ///
  /// In en, this message translates to:
  /// **'saved a month'**
  String get loanStatSave;

  /// No description provided for @loanStatEmi.
  ///
  /// In en, this message translates to:
  /// **'loan a month'**
  String get loanStatEmi;

  /// No description provided for @loanStatCover.
  ///
  /// In en, this message translates to:
  /// **'coverage'**
  String get loanStatCover;

  /// No description provided for @loanTerms.
  ///
  /// In en, this message translates to:
  /// **'Your loan'**
  String get loanTerms;

  /// No description provided for @loanShare.
  ///
  /// In en, this message translates to:
  /// **'Borrow {pct}% of the cost'**
  String loanShare(String pct);

  /// No description provided for @loanYears.
  ///
  /// In en, this message translates to:
  /// **'Pay back over {years} years'**
  String loanYears(String years);

  /// No description provided for @loanRate.
  ///
  /// In en, this message translates to:
  /// **'Interest {rate}% a year'**
  String loanRate(String rate);

  /// No description provided for @loanRateNote.
  ///
  /// In en, this message translates to:
  /// **'Use the rate your bank quotes. These are your assumptions, not a loan offer.'**
  String get loanRateNote;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loanAmount;

  /// No description provided for @loanOwnMoney.
  ///
  /// In en, this message translates to:
  /// **'Your own money'**
  String get loanOwnMoney;

  /// No description provided for @loanInterestTotal.
  ///
  /// In en, this message translates to:
  /// **'Total interest'**
  String get loanInterestTotal;

  /// No description provided for @loanAfter.
  ///
  /// In en, this message translates to:
  /// **'After the loan is paid: Tk {amount} more savings over {years} years'**
  String loanAfter(String years, String amount);

  /// No description provided for @loanReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for the bank? {done} of {total}'**
  String loanReadyTitle(String done, String total);

  /// No description provided for @loanCheckBills.
  ///
  /// In en, this message translates to:
  /// **'12 months of bills'**
  String get loanCheckBills;

  /// No description provided for @loanCheckBillsDetail.
  ///
  /// In en, this message translates to:
  /// **'{months} so far'**
  String loanCheckBillsDetail(String months);

  /// No description provided for @loanCheckOwnUse.
  ///
  /// In en, this message translates to:
  /// **'Solar sized on your own electricity use'**
  String get loanCheckOwnUse;

  /// No description provided for @loanCheckCover.
  ///
  /// In en, this message translates to:
  /// **'Savings cover the loan payment'**
  String get loanCheckCover;

  /// No description provided for @loanCheckRoof.
  ///
  /// In en, this message translates to:
  /// **'Roof checked by an engineer'**
  String get loanCheckRoof;

  /// No description provided for @loanCheckFactors.
  ///
  /// In en, this message translates to:
  /// **'Emission factors verified'**
  String get loanCheckFactors;

  /// No description provided for @loanCheckProfile.
  ///
  /// In en, this message translates to:
  /// **'Factory profile has location and workers'**
  String get loanCheckProfile;

  /// No description provided for @loanWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to apply'**
  String get loanWhereTitle;

  /// No description provided for @loanWhere.
  ///
  /// In en, this message translates to:
  /// **'Ask your bank about green finance for rooftop solar. Banks in Bangladesh can lend for it under Bangladesh Bank\'s sustainable finance policy and green refinance schemes, and IDCOL supports rooftop solar through partner organisations. The lender sets the terms.'**
  String get loanWhere;

  /// No description provided for @loanPdf.
  ///
  /// In en, this message translates to:
  /// **'Bank summary (PDF)'**
  String get loanPdf;

  /// No description provided for @loanDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A pre-feasibility estimate, not a credit assessment. Bring an installer\'s quote and a roof check to the bank.'**
  String get loanDisclaimer;

  /// No description provided for @loanNoFinancials.
  ///
  /// In en, this message translates to:
  /// **'This solar plan has no savings estimate yet. Add electricity bills with the amount paid, then estimate solar again.'**
  String get loanNoFinancials;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Solar preview'**
  String get previewTitle;

  /// No description provided for @previewOpen.
  ///
  /// In en, this message translates to:
  /// **'See solar on your roof'**
  String get previewOpen;

  /// No description provided for @previewBefore.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get previewBefore;

  /// No description provided for @previewAfter.
  ///
  /// In en, this message translates to:
  /// **'With solar'**
  String get previewAfter;

  /// No description provided for @previewPanels.
  ///
  /// In en, this message translates to:
  /// **'{count} panels · {kwp} kWp'**
  String previewPanels(String count, String kwp);

  /// No description provided for @previewFitNote.
  ///
  /// In en, this message translates to:
  /// **'The drawing shows {drawn} of {count} panels, keeping 1 m from the roof edges. An installer will plan the exact layout.'**
  String previewFitNote(String drawn, String count);

  /// No description provided for @previewHeadline.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of your electricity would come from your own roof'**
  String previewHeadline(String pct);

  /// No description provided for @previewStatSolar.
  ///
  /// In en, this message translates to:
  /// **'kWh from solar'**
  String get previewStatSolar;

  /// No description provided for @previewStatGridCut.
  ///
  /// In en, this message translates to:
  /// **'less from grid'**
  String get previewStatGridCut;

  /// No description provided for @previewStatSaved.
  ///
  /// In en, this message translates to:
  /// **'saved on bills'**
  String get previewStatSaved;

  /// No description provided for @previewCompare.
  ///
  /// In en, this message translates to:
  /// **'Before and after solar'**
  String get previewCompare;

  /// No description provided for @previewPeriod.
  ///
  /// In en, this message translates to:
  /// **'Your bills from {from} to {to}'**
  String previewPeriod(String from, String to);

  /// No description provided for @previewGrid.
  ///
  /// In en, this message translates to:
  /// **'Electricity bought from the grid'**
  String get previewGrid;

  /// No description provided for @previewBill.
  ///
  /// In en, this message translates to:
  /// **'Electricity bill'**
  String get previewBill;

  /// No description provided for @previewCo2.
  ///
  /// In en, this message translates to:
  /// **'CO₂ from electricity'**
  String get previewCo2;

  /// No description provided for @previewNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get previewNow;

  /// No description provided for @previewWithSolar.
  ///
  /// In en, this message translates to:
  /// **'With solar'**
  String get previewWithSolar;

  /// No description provided for @previewMonthly.
  ///
  /// In en, this message translates to:
  /// **'Month by month: where your power comes from'**
  String get previewMonthly;

  /// No description provided for @previewFromGrid.
  ///
  /// In en, this message translates to:
  /// **'From the grid'**
  String get previewFromGrid;

  /// No description provided for @previewFromSolar.
  ///
  /// In en, this message translates to:
  /// **'From your roof'**
  String get previewFromSolar;

  /// No description provided for @previewNoBills.
  ///
  /// In en, this message translates to:
  /// **'Add electricity bills to compare your real use with solar.'**
  String get previewNoBills;

  /// No description provided for @previewNote.
  ///
  /// In en, this message translates to:
  /// **'Estimate from your own bills and the solar plan (first year). Solar power the factory cannot use (holidays, weekends) is not counted as savings. The panels are drawn to show the idea; an installer will make the real layout.'**
  String get previewNote;

  /// No description provided for @solarPaybackOver.
  ///
  /// In en, this message translates to:
  /// **'Over {years} years'**
  String solarPaybackOver(String years);

  /// No description provided for @solarSayTooLong.
  ///
  /// In en, this message translates to:
  /// **'It saves about Tk {tk} a year, so the Tk {capex} system would not pay for itself within the panels\' {years}-year life. Add all your electricity bills, or draw only the part of the roof your factory needs.'**
  String solarSayTooLong(String tk, String capex, String years);

  /// No description provided for @view3dTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory in 3D'**
  String get view3dTitle;

  /// No description provided for @view3dOpen.
  ///
  /// In en, this message translates to:
  /// **'3D view'**
  String get view3dOpen;

  /// No description provided for @view3dReset.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get view3dReset;

  /// No description provided for @view3dLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading 3D buildings…'**
  String get view3dLoading;

  /// No description provided for @view3dError.
  ///
  /// In en, this message translates to:
  /// **'The 3D view could not load. Check the internet connection and try again.'**
  String get view3dError;

  /// No description provided for @view3dReal.
  ///
  /// In en, this message translates to:
  /// **'Real 3D'**
  String get view3dReal;

  /// No description provided for @view3dModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get view3dModel;

  /// No description provided for @view3dFloors.
  ///
  /// In en, this message translates to:
  /// **'Floors: {count}'**
  String view3dFloors(String count);

  /// No description provided for @view3dRealHint.
  ///
  /// In en, this message translates to:
  /// **'Google\'s 3D buildings. If your roof looks flat or blurry, switch to Model.'**
  String get view3dRealHint;

  /// No description provided for @view3dGesture.
  ///
  /// In en, this message translates to:
  /// **'Drag to move · pinch to zoom · two fingers to turn and tilt'**
  String get view3dGesture;
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
