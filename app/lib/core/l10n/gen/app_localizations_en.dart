// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Factory Energy & Carbon';

  @override
  String get navHome => 'Home';

  @override
  String get navBills => 'Bills';

  @override
  String get navReports => 'Reports';

  @override
  String get navSolar => 'Solar';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionClose => 'Close';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionClear => 'Clear';

  @override
  String get syntheticBadge => 'SYNTHETIC DATA';

  @override
  String get syntheticBanner =>
      'This app contains synthetic demo data. Results do not describe a real factory.';

  @override
  String get unverifiedFactorBadge => 'Unverified factor';

  @override
  String get notAvailable => 'Not available';

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String get showingSaved =>
      'Showing the saved result. Update it when you are online.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get errorNetwork =>
      'Could not reach the server. Check your internet connection and the server address in Settings.';

  @override
  String get errorTimeout => 'The server took too long to respond.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorServer => 'The server had a problem. Please try again.';

  @override
  String get errorUnavailable =>
      'This feature is not available on the server right now.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get invalidNonNegative => 'Must be zero or more';

  @override
  String get invalidLatitude => 'Latitude must be between -90 and 90';

  @override
  String get invalidLongitude => 'Longitude must be between -180 and 180';

  @override
  String get invalidFraction => 'Enter a value between 0 and 1';

  @override
  String get invalidMonth => 'Select a month';

  @override
  String get onboardingTitle => 'Set up your factory';

  @override
  String get onboardingIntro =>
      'Turn utility bills into a carbon report for buyers, get warnings about high electricity use and estimate rooftop solar.';

  @override
  String get factoryNameLabel => 'Factory name';

  @override
  String get factoryLocationLabel => 'Location (city, district)';

  @override
  String get factoryLatLabel => 'Latitude (optional)';

  @override
  String get factoryLonLabel => 'Longitude (optional)';

  @override
  String get productionUnitLabel => 'Production unit (e.g. pieces)';

  @override
  String get privacyTitle => 'Your data and privacy';

  @override
  String get privacyBody =>
      '• Your factory profile, bills, production and reports are stored only on this phone.\n• When you scan a bill, the cropped photo is sent to our server and to Google\'s Gemini API to read the values. Crop out names, addresses and consumer or meter numbers first.\n• Our server does not store your photos or data. Google handles uploads under its Gemini API terms: if the server uses Google\'s free tier, Google may use uploads to improve its products and people at Google may review them.\n• Carbon, waste, solar and PDF calculations send the needed numbers to our server; nothing is stored there.';

  @override
  String get privacyAcknowledge =>
      'I have read and understand how my data is handled';

  @override
  String get privacyMustAcknowledge =>
      'Please confirm you have read the privacy notice.';

  @override
  String get onboardingStart => 'Start';

  @override
  String get uploadNoticeTitle => 'Before your first upload';

  @override
  String get uploadNoticeBody =>
      'The photo will be sent to our server and to Google\'s Gemini API to read the bill. Before sending, you crop the bill and cover names, addresses, consumer and meter numbers with black boxes. Photos are not stored on our server. On Google\'s free tier, Google may use uploads to improve its products and people may review them.';

  @override
  String get uploadNoticeAccept => 'I understand, continue';

  @override
  String get homeLatestReport => 'Latest carbon report';

  @override
  String get homeNoReport =>
      'No report yet. Add bills or import history, then open Reports.';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeImportHistory => 'Import history (CSV)';

  @override
  String get homeProduction => 'Production';

  @override
  String get homeWaste => 'Electricity waste check';

  @override
  String get homeCarbon => 'Carbon report';

  @override
  String homeBillsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString bills saved',
      one: '1 bill saved',
      zero: 'No bills saved',
    );
    return '$_temp0';
  }

  @override
  String get addBillTitle => 'Add bill';

  @override
  String get addBillCamera => 'Take photo';

  @override
  String get addBillGallery => 'Choose from gallery';

  @override
  String get addBillManual => 'Enter manually (no image)';

  @override
  String get addBillManualHint =>
      'For diesel receipts, unmetered gas, or when a photo cannot be read.';

  @override
  String get cropTitle => 'Crop the bill';

  @override
  String get cropReminder =>
      'First trim the photo to the bill. In the next step you can cover any names, addresses, consumer or meter numbers that are inside it.';

  @override
  String get preparingImage => 'Preparing image…';

  @override
  String uploadProgress(String percent) {
    return 'Uploading $percent%';
  }

  @override
  String get uploadReading => 'Reading values. This can take up to a minute.';

  @override
  String get uploadFailedTitle => 'Could not read the bill';

  @override
  String get uploadEnterManually => 'Enter manually instead';

  @override
  String get reviewTitle => 'Check the values';

  @override
  String get reviewIntro =>
      'Values were read automatically. Compare each one with the image. Highlighted fields need extra care.';

  @override
  String get reviewManualIntro => 'Enter the values from your bill or receipt.';

  @override
  String get lowConfidence => 'Low confidence: check this on the image';

  @override
  String get fieldBillType => 'Bill type';

  @override
  String get billTypeElectricity => 'Electricity';

  @override
  String get billTypeGas => 'Gas';

  @override
  String get billTypeDiesel => 'Diesel';

  @override
  String get billTypeUnknown => 'Unknown';

  @override
  String get fieldUtilityName => 'Utility / supplier';

  @override
  String get fieldBillingMonth => 'Billing month';

  @override
  String get fieldPeriodStart => 'Period start';

  @override
  String get fieldPeriodEnd => 'Period end';

  @override
  String get fieldConsumedUnits => 'Consumed units';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldTotalAmount => 'Total payable (Tk)';

  @override
  String get fieldTariffCode => 'Tariff code';

  @override
  String get fieldSanctionedLoad => 'Sanctioned load (kW)';

  @override
  String get fieldNotes => 'Notes from the reader';

  @override
  String get notSet => 'Not set';

  @override
  String get selectBillType => 'Select the bill type';

  @override
  String unitMismatch(String unit) {
    return 'Unit must be $unit for this bill type';
  }

  @override
  String get reviewConfirm => 'I have checked these values against the bill';

  @override
  String get reviewMustConfirm =>
      'Tick the box to confirm you checked the values.';

  @override
  String get duplicateTitle => 'Possible duplicate';

  @override
  String duplicateBody(String type, String month) {
    return 'A $type bill for $month is already saved. Save this one too?';
  }

  @override
  String get duplicateSaveAnyway => 'Save anyway';

  @override
  String get billSaved => 'Bill saved';

  @override
  String get imageWillBeDeleted =>
      'The photo is deleted from this phone after saving.';

  @override
  String get imageWillBeKept => 'The photo is kept on this phone (Settings).';

  @override
  String get warnUnknownBillType =>
      'Bill type could not be identified. Please select it.';

  @override
  String get warnPeriodEndBeforeStart => 'Period end is before period start.';

  @override
  String get warnUnusualPeriodLength =>
      'The billing period length is unusual for a monthly bill.';

  @override
  String get warnMonthPeriodMismatch =>
      'Billing month does not match the period end date.';

  @override
  String get warnUnitsNotPositive =>
      'Consumed units should be greater than zero.';

  @override
  String get warnUnitsAboveCeiling =>
      'Consumed units are unusually high. Please check.';

  @override
  String get warnUnitTypeMismatch => 'This unit is unusual for this bill type.';

  @override
  String get warnPriceOutOfBand =>
      'Amount per unit is outside the usual range. Check the units and the amount.';

  @override
  String get warnLowConfidence =>
      'The reader was not confident about this value. Check it on the image.';

  @override
  String get billsTitle => 'Bills';

  @override
  String get billsEmpty => 'No bills yet. Add a bill or import history.';

  @override
  String get billOriginImage => 'From photo';

  @override
  String get billOriginManual => 'Manual';

  @override
  String get billOriginImported => 'Imported (not from a bill image)';

  @override
  String get billOriginDemo => 'Synthetic';

  @override
  String get billEdited => 'Edited';

  @override
  String get deleteBillConfirm => 'Delete this bill?';

  @override
  String get editBillTitle => 'Edit bill';

  @override
  String get productionTitle => 'Production';

  @override
  String get productionEmpty => 'No production data yet.';

  @override
  String get productionMonth => 'Month';

  @override
  String productionUnits(String unit) {
    return 'Units produced ($unit)';
  }

  @override
  String get productionAdd => 'Add production';

  @override
  String get productionReplaceNote =>
      'Saving a month that already exists replaces its value.';

  @override
  String get importTitle => 'Import history';

  @override
  String get importIntro =>
      'Fill 12–24 months in the template: month, electricity kWh, diesel litres, gas m³ and production (electricity cost is optional). Then import it here.';

  @override
  String get importGetTemplate => 'Get template';

  @override
  String get importPickFile => 'Choose CSV file';

  @override
  String importRowsReady(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months ready to import',
      one: '1 month ready to import',
    );
    return '$_temp0';
  }

  @override
  String get importErrors => 'Fix these problems and choose the file again:';

  @override
  String get importWarnings => 'Warnings';

  @override
  String get importConfirm => 'Import';

  @override
  String importDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months imported',
      one: '1 month imported',
    );
    return '$_temp0';
  }

  @override
  String get importMarked =>
      'Imported rows are marked \"imported (not from a bill image)\" and listed in data-quality notes.';

  @override
  String get importFewMonths =>
      'Fewer than 12 months: the waste check needs at least 6, a full year is better.';

  @override
  String issueMissingColumns(String columns) {
    return 'Missing columns: $columns';
  }

  @override
  String get issueNoRows => 'The file has no data rows.';

  @override
  String issueBadMonth(String row, String value) {
    return 'Row $row: month \"$value\" must be YYYY-MM';
  }

  @override
  String issueBadNumber(String row, String column, String value) {
    return 'Row $row: $column \"$value\" is not a number';
  }

  @override
  String issueNegative(String row, String column) {
    return 'Row $row: $column cannot be negative';
  }

  @override
  String issueDuplicateMonth(String row, String value) {
    return 'Row $row: month $value appears more than once';
  }

  @override
  String issueEmptyRow(String row, String value) {
    return 'Row $row: no values for $value; skipped';
  }

  @override
  String issueCostWithoutKwh(String row, String value) {
    return 'Row $row: cost without kWh for $value; cost ignored';
  }

  @override
  String get importColMonth => 'Month';

  @override
  String get importColKwh => 'kWh';

  @override
  String get importColDiesel => 'Diesel L';

  @override
  String get importColGas => 'Gas m³';

  @override
  String get importColProduction => 'Production';

  @override
  String get carbonTitle => 'Carbon report';

  @override
  String get carbonCalculate => 'Update report';

  @override
  String get carbonNoData =>
      'No confirmed data yet. Add bills or import history.';

  @override
  String get carbonScope1 => 'Scope 1 (diesel + gas)';

  @override
  String get carbonScope2 => 'Scope 2 (grid electricity)';

  @override
  String get carbonTotal => 'Total';

  @override
  String carbonIntensity(String unit) {
    return 'Per 1,000 $unit';
  }

  @override
  String tonnesCo2e(String value) {
    return '$value tCO2e';
  }

  @override
  String get carbonMonthly => 'Monthly emissions';

  @override
  String get carbonPartialMonth =>
      '* partial month (missing data or factor). Empty months have no data; they are not zero.';

  @override
  String get carbonFactorsTitle => 'Emission factors';

  @override
  String get carbonQualityTitle => 'Data quality';

  @override
  String carbonFactorNotSet(String factor) {
    return 'The $factor emission factor is not set on the server, so these emissions are not calculated.';
  }

  @override
  String get factorGrid => 'grid electricity';

  @override
  String get factorDiesel => 'diesel';

  @override
  String get factorGas => 'natural gas';

  @override
  String get factorStatusVerified => 'Verified';

  @override
  String factorSource(String source) {
    return 'Source: $source';
  }

  @override
  String factorYear(String year) {
    return 'Year: $year';
  }

  @override
  String get legendElectricity => 'Electricity';

  @override
  String get legendDiesel => 'Diesel';

  @override
  String get legendGas => 'Gas';

  @override
  String monthsSummary(String withData, String total, String complete) {
    return '$withData of $total months have data, $complete complete';
  }

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportRaw => 'Export raw data (CSV)';

  @override
  String get exportNeedsResult => 'Update the report first.';

  @override
  String get exporting => 'Preparing…';

  @override
  String get methodologyTitle => 'Methodology';

  @override
  String get methodologyBody =>
      'Scope 2 (location-based) = electricity kWh × grid emission factor. Scope 1 = diesel litres × diesel factor + gas m³ × gas factor. Results are in tonnes CO2e. Intensity is shown only for complete months with production.';

  @override
  String noteMissingData(String source) {
    return 'No $source data for these months. They are shown as empty, not zero.';
  }

  @override
  String get noteMonthsWithoutData => 'No energy data at all for these months.';

  @override
  String get noteMissingProduction =>
      'Production is missing for these months, so intensity is not shown.';

  @override
  String get noteMultipleEntries =>
      'More than one entry of the same type in these months; quantities were added. Check for duplicates.';

  @override
  String get noteUserEdited =>
      'Some values were corrected by you after automatic reading.';

  @override
  String get noteManualEntries =>
      'Some entries were typed in manually without a bill image.';

  @override
  String get noteImportedHistory =>
      'Some data was imported from a spreadsheet (not from a bill image).';

  @override
  String get noteSyntheticData =>
      'SYNTHETIC demo data is included. These results do not describe a real factory.';

  @override
  String get notePlaceholderFactors =>
      'Unverified (PLACEHOLDER) emission factors are in use. Verify them before any real submission.';

  @override
  String get noteIncompleteTotals =>
      'Totals include months with missing sources or factors, so they understate the true footprint.';

  @override
  String get noteNoData => 'No confirmed bills or production data.';

  @override
  String get wasteTitle => 'Electricity waste check';

  @override
  String get wasteAnalyze => 'Check now';

  @override
  String wasteInsufficient(String count, String required) {
    return 'Only $count months of electricity data. At least $required months are needed.';
  }

  @override
  String get wasteImportPrompt => 'Import past bills';

  @override
  String get wasteMethodOls =>
      'Expected use is based on your production level.';

  @override
  String get wasteMethodMad =>
      'Lower confidence, no production data: compared with a typical month.';

  @override
  String get wasteActual => 'Actual';

  @override
  String get wasteExpected => 'Expected';

  @override
  String get wasteBand => 'Normal range (95%)';

  @override
  String wasteFlagMessage(String month, String pct, String kwh, String cost) {
    return '$month used about $pct% more electricity than expected for the units produced; about $kwh kWh$cost. Check compressors, idle machines and generator changeover.';
  }

  @override
  String wasteFlagMessageMad(
    String month,
    String pct,
    String kwh,
    String cost,
  ) {
    return '$month used about $pct% more electricity than a typical month; about $kwh kWh$cost. Check compressors, idle machines and generator changeover.';
  }

  @override
  String wasteCostPart(String amount) {
    return ', about Tk $amount';
  }

  @override
  String get wasteNoCost => ' (cost unknown: no bill amounts)';

  @override
  String get wasteNoFlags =>
      'No month used clearly more electricity than expected.';

  @override
  String get wasteHowTitle => 'How this works and its limits';

  @override
  String get wasteHowBody =>
      'With at least 6 months of electricity and production data, the app fits a straight line of kWh against production. For each month it predicts the expected kWh from the other months and a 95% range. Months above the range are flagged.\n\nWithout production data it compares each month with your typical month. This is less reliable.\n\nLimits:\n• Only monthly totals, a small sample: results are indicative.\n• Without sub-metering it cannot tell which machine used the extra electricity.\n• It flags statistical outliers; it cannot identify the cause.\n• Product mix, working hours, weather or new machines can explain a flag.';

  @override
  String wasteFlaggedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months flagged',
      one: '1 month flagged',
      zero: 'No months flagged',
    );
    return '$_temp0';
  }

  @override
  String get solarTitle => 'Rooftop solar';

  @override
  String get solarNewPlan => 'New plan';

  @override
  String get solarNoPlans => 'No saved plans. Draw your roof to start.';

  @override
  String get solarDrawHint =>
      'Tap the roof corners on the map. Use undo to fix mistakes.';

  @override
  String solarPoints(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString corners',
      one: '1 corner',
    );
    return '$_temp0';
  }

  @override
  String get solarNeedPoints => 'Tap at least 3 corners.';

  @override
  String get solarLayerStreet => 'Map';

  @override
  String get solarLayerSatellite => 'Satellite';

  @override
  String get solarSatelliteUnavailable =>
      'Satellite imagery is not configured. Building outlines are visible on the map at high zoom.';

  @override
  String get solarParamsTitle => 'Parameters';

  @override
  String get paramUsableRoof => 'Usable roof fraction';

  @override
  String get paramM2PerKwp => 'm² per kWp';

  @override
  String get paramPerformanceRatio => 'Performance ratio';

  @override
  String get paramDegradation => 'Degradation per year';

  @override
  String get paramCapex => 'Capex (Tk per kWp, optional)';

  @override
  String get paramOm => 'O&M (fraction of capex per year, optional)';

  @override
  String get paramPrice => 'Electricity price (Tk/kWh, optional)';

  @override
  String get paramPriceHint => 'Default: average from your bills';

  @override
  String get paramExportPrice => 'Export price (Tk/kWh, optional)';

  @override
  String get paramNetMetering => 'Net metering';

  @override
  String get paramPsh => 'Peak sun hours (optional)';

  @override
  String get paramPshHint => 'Leave empty to use NASA POWER data';

  @override
  String paramDefault(String value) {
    return 'Default $value';
  }

  @override
  String get solarEstimate => 'Estimate';

  @override
  String get solarResultTitle => 'Solar estimate';

  @override
  String get solarRoofArea => 'Roof area';

  @override
  String get solarUsableArea => 'Usable area';

  @override
  String get solarSize => 'System size';

  @override
  String get solarAnnualGen => 'Annual generation';

  @override
  String get solarOffset => 'Share of consumption offset';

  @override
  String get solarCo2 => 'CO2 avoided per year';

  @override
  String get solarPsh => 'Peak sun hours (average)';

  @override
  String get solarSourceNasa => 'NASA POWER';

  @override
  String get solarSourceManual => 'Manual';

  @override
  String get solarFinancials => 'Financials';

  @override
  String get solarCapex => 'Investment';

  @override
  String get solarYear1Savings => 'Year-1 savings';

  @override
  String get solarYear1Om => 'Year-1 O&M';

  @override
  String get solarPayback => 'Simple payback';

  @override
  String get solarNoPayback => 'No payback';

  @override
  String get solarNoFinancials =>
      'Enter a capex per kWp to see savings and payback.';

  @override
  String get solarCashflow => 'Cumulative cash flow (million Tk)';

  @override
  String get solarSavePlan => 'Save plan';

  @override
  String get solarPlanName => 'Plan name';

  @override
  String get solarPlanSaved => 'Plan saved';

  @override
  String get solarNotes => 'Notes';

  @override
  String get solarDisclaimer =>
      'Pre-feasibility estimate. Structural load, shading and electrical design need a professional assessment.';

  @override
  String valueYears(String value) {
    return '$value years';
  }

  @override
  String valueKwp(String value) {
    return '$value kWp';
  }

  @override
  String valueKwhYear(String value) {
    return '$value kWh/year';
  }

  @override
  String valueM2(String value) {
    return '$value m²';
  }

  @override
  String valueTk(String value) {
    return 'Tk $value';
  }

  @override
  String valuePercent(String value) {
    return '$value%';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Device default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get settingsKeepImages => 'Keep bill images on this phone';

  @override
  String get settingsKeepImagesHint =>
      'Off: photos are deleted once the values are read.';

  @override
  String get settingsFactory => 'Factory profile';

  @override
  String get settingsDataHandling => 'How your data is handled';

  @override
  String get settingsLimitations => 'Known limitations';

  @override
  String get settingsLoadDemo => 'Load demo data (synthetic)';

  @override
  String get settingsLoadDemoHint =>
      'Adds 24 months of made-up bills and production with 2 injected anomalies.';

  @override
  String get settingsRemoveDemo => 'Remove demo data';

  @override
  String get demoLoaded => 'Synthetic demo data loaded';

  @override
  String get demoRemoved => 'Demo data removed';

  @override
  String get settingsDeleteAll => 'Delete all my data';

  @override
  String get deleteAllConfirmTitle => 'Delete all data?';

  @override
  String get deleteAllConfirmBody =>
      'This permanently deletes the factory profile, bills, production, solar plans, saved reports and kept images from this phone. It cannot be undone.';

  @override
  String get deleteAllDone => 'All data deleted';

  @override
  String get settingsServer => 'Server';

  @override
  String get serverStatusOk => 'Connected';

  @override
  String get serverStatusError => 'Not reachable';

  @override
  String get serverExtractionOff =>
      'Bill reading is not configured on the server; use manual entry.';

  @override
  String get settingsExport => 'Export';

  @override
  String get dataHandlingTitle => 'How your data is handled';

  @override
  String get dataHandlingPhoneTitle => 'Stored on this phone';

  @override
  String get dataHandlingPhoneBody =>
      'Factory profile, confirmed bills, production, solar plans and the last calculated reports. Bill photos only if you turn on \"Keep bill images\". Delete everything any time in Settings.';

  @override
  String get dataHandlingServerTitle => 'Sent to our server';

  @override
  String get dataHandlingServerBody =>
      'The cropped bill photo (to read it), and the numbers needed for each calculation: monthly quantities, amounts, production, roof outline. The server keeps nothing: no database, no stored images, no logged request contents.';

  @override
  String get dataHandlingGoogleTitle => 'Sent to Google';

  @override
  String get dataHandlingGoogleBody =>
      'The cropped bill photo is passed to Google\'s Gemini API to read the values, under Google\'s Gemini API terms. On Google\'s free (unpaid) tier, Google may use the content to improve its products and human reviewers may read it; on a paid (billing-enabled) project it does not use it for that. Crop out personal details before uploading. The app never asks Gemini for names, addresses, consumer or meter numbers.';

  @override
  String get dataHandlingNasaTitle => 'Sent to NASA POWER';

  @override
  String get dataHandlingNasaBody =>
      'For solar estimates our server asks NASA POWER for sunlight data at the roof\'s approximate location (rounded). No other data is sent.';

  @override
  String get limitationsTitle => 'Known limitations';

  @override
  String get limitationsBody =>
      '• Scope 1 and 2 from utility bills only. No Scope 3; no coal, biomass or other fuels unless entered manually.\n• Bill-reading accuracy has only been measured on a few sample bills. Always check values.\n• The waste check flags statistical outliers against production; it cannot identify causes.\n• Solar results are pre-feasibility estimates only.\n• Emission factors come from published government sources (shown with source and year in the report). Update them when newer editions appear and confirm they match the buyer\'s rules.\n• The app token is weak protection, adequate for a demo only.';

  @override
  String get demoNeedsEmpty =>
      'Demo data can only be loaded when the app has no real bills or production. Export or delete your data first.';

  @override
  String get carbonStale =>
      'Your data changed after this report was calculated. Update it.';

  @override
  String get serverSettingsTitle => 'Server connection';

  @override
  String get serverUrlLabel => 'Server address';

  @override
  String get serverUrlHint =>
      'e.g. 192.168.1.20:8000 or https://api.example.com';

  @override
  String get serverTokenLabel => 'App token';

  @override
  String get serverTest => 'Test connection';

  @override
  String get serverReset => 'Use default';

  @override
  String get serverInvalidUrl =>
      'Enter a valid address, e.g. 192.168.1.20:8000';

  @override
  String get serverSaved => 'Server settings saved';

  @override
  String get serverTestOk => 'Connected to the server.';

  @override
  String get serverHelp =>
      'Testing with your phone? Run start_backend.ps1 on your computer, connect the phone and the computer to the same Wi-Fi, then enter the address and token the script prints (for example 192.168.1.20:8000).';

  @override
  String serverCurrent(String url) {
    return 'Now using: $url';
  }

  @override
  String get languageChoose => 'Language / ভাষা';

  @override
  String get pickMonth => 'Select month';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get homeGettingStarted => 'Getting started';

  @override
  String get stepAddData => 'Add a bill or import past months';

  @override
  String get stepProduction => 'Enter monthly production';

  @override
  String get stepReport => 'Create your carbon report';

  @override
  String get stepWaste => 'Check for electricity waste';

  @override
  String get homeStatMonths => 'Months';

  @override
  String get homeStatLatest => 'Latest month';

  @override
  String get homeTryDemo =>
      'Just looking around? Load synthetic demo data to see every feature.';

  @override
  String get homeLoadDemo => 'Load demo data';

  @override
  String get filterAll => 'All';

  @override
  String get reviewMainSection => 'Main values';

  @override
  String get reviewMoreDetails => 'More details (optional)';

  @override
  String get reviewImageHint => 'Pinch to zoom the bill';

  @override
  String get addBillScanTitle => 'Scan a bill';

  @override
  String get addBillScanHint =>
      'Take or choose a photo. You will hide personal details and check every value before saving.';

  @override
  String get solarMyLocation => 'Go to factory location';

  @override
  String get errInvalidPolygon =>
      'The roof outline is not valid. Make sure its edges do not cross.';

  @override
  String get errPolygonTooSmall =>
      'The roof outline is too small. Zoom in and tap the roof corners.';

  @override
  String get errPolygonTooLarge =>
      'The roof outline is too large. Draw only the factory roof.';

  @override
  String get errUnitMismatch =>
      'A saved entry has the wrong unit for its type. Fix it in Bills.';

  @override
  String get errIrradiance =>
      'Could not get sunlight data. Enter peak sun hours manually or try again.';

  @override
  String get errDailyCap =>
      'Today\'s bill-reading limit is reached. Try tomorrow or enter the bill manually.';

  @override
  String get errExtractionFailed =>
      'Could not read the bill. Try a clearer photo or enter it manually.';

  @override
  String get errFileTooLarge => 'The photo is too large.';

  @override
  String get errUnsupportedFile => 'Use a JPG, PNG or PDF file.';

  @override
  String get errInvalidToken =>
      'The server rejected the app token. Check Server connection in Settings.';

  @override
  String get errExtractionUnavailable =>
      'Bill reading is not set up on the server yet. Enter the bill manually.';

  @override
  String swConsumptionPartial(String count) {
    return 'Your electricity history covers $count of 12 months; the others use your average month.';
  }

  @override
  String swExcessNotCounted(String kwh) {
    return 'About $kwh kWh/year is more than you use in those months and is not counted (no net metering).';
  }

  @override
  String get swNoConsumption =>
      'No electricity bills yet, so the share of use covered and savings cannot be estimated.';

  @override
  String get swGridFactorNotSet =>
      'The grid emission factor is not set on the server, so CO2 avoided is not calculated.';

  @override
  String get swCo2NeedsConsumption =>
      'CO2 avoided needs your electricity history (or net metering).';

  @override
  String get swGridPlaceholder =>
      'CO2 avoided uses an unverified grid emission factor.';

  @override
  String get swPriceMissing =>
      'Savings need an electricity price: enter one, or add bills with amounts.';

  @override
  String get swFinancialsNeedConsumption =>
      'Savings need your electricity history when there is no net metering.';

  @override
  String get swOmNotIncluded => 'Maintenance (O&M) cost is not included.';

  @override
  String get swExportPriceMissing =>
      'Net metering is on but no export price is set; exported energy is valued at zero.';

  @override
  String get swFinancialAssumptions =>
      'Assumes a constant electricity price and no loan cost.';

  @override
  String get swNoPayback =>
      'Yearly savings do not cover maintenance, so there is no payback.';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introGetStarted => 'Get started';

  @override
  String get intro1Title => 'Snap a bill. We read it.';

  @override
  String get intro1Body =>
      'Take a photo of your electricity, gas or diesel bill. AI reads the numbers, and you check them before anything is saved.';

  @override
  String get intro2Title => 'Carbon report in one tap';

  @override
  String get intro2Body =>
      'Get the Scope 1 + 2 carbon report your buyers ask for, ready to share as PDF or spreadsheet.';

  @override
  String get intro3Title => 'Cut waste. Go solar.';

  @override
  String get intro3Body =>
      'Spot months with unusually high electricity use, and estimate what rooftop solar could save you.';

  @override
  String get introPrivacyNote => 'Your data stays on this phone.';

  @override
  String get onboardingFormSubtitle =>
      'A few details for your reports. You can change them later.';

  @override
  String get factoryCoordsHint =>
      'Optional. Used to centre the solar map on your factory.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeFootprint => 'Carbon footprint';

  @override
  String get homeHeroEmpty =>
      'Let\'s measure your factory\'s energy and carbon.';

  @override
  String get homeScanTitle => 'Scan a bill';

  @override
  String get homeScanSubtitle =>
      'Take a photo of an electricity, gas or diesel bill. We read the numbers for you.';

  @override
  String get homeExplore => 'What would you like to do?';

  @override
  String get tileBillsSub => 'See and edit saved bills';

  @override
  String get tileImportSub => 'Add past months from a spreadsheet';

  @override
  String get tileProductionSub => 'Monthly output for intensity';

  @override
  String get tileCarbonSub => 'Scope 1 + 2 report and PDF';

  @override
  String get tileWasteSub => 'Find unusual electricity use';

  @override
  String get tileSolarSub => 'Rooftop solar estimate';

  @override
  String get connOfflineTitle => 'Not connected to the server';

  @override
  String get connOfflineBody =>
      'Bill reading, reports and solar need the server. Your saved data is safe on this phone.';

  @override
  String get connOnline => 'Server connected';

  @override
  String get connChecking => 'Checking connection…';

  @override
  String get connReadingOn => 'Bill reading ready';

  @override
  String get uploadStepSend => 'Sending the photo';

  @override
  String get uploadStepRead => 'AI is reading the bill';

  @override
  String get uploadStepReview => 'You check every value';

  @override
  String get addBillTipsTitle => 'Tips for a good photo';

  @override
  String get addBillTip1 => 'Lay the bill flat in good light';

  @override
  String get addBillTip2 => 'Fit the whole bill in the frame';

  @override
  String get addBillTip3 => 'Cover names, addresses and account numbers';

  @override
  String get addBillOr => 'or';

  @override
  String get billsSubtitle => 'All your energy bills in one place';

  @override
  String get reportsSubtitle => 'Your carbon footprint and electricity waste';

  @override
  String get solarSubtitle => 'Estimate rooftop solar for your factory';

  @override
  String get settingsSubtitle => 'Language, server, privacy and your data';

  @override
  String get solarHowTitle => 'How it works';

  @override
  String get solarHow1 => 'Draw your roof on the map';

  @override
  String get solarHow2 => 'Check the assumptions';

  @override
  String get solarHow3 => 'See size, output and payback';

  @override
  String get wasteAllGoodTitle => 'All good';

  @override
  String get wasteAttentionTitle => 'Needs attention';

  @override
  String get carbonScopeSplit => 'Scope 1 (fuel) vs Scope 2 (electricity)';

  @override
  String get reviewAiRead => 'Read by AI';

  @override
  String get reviewManualBadge => 'Manual entry';

  @override
  String get redactTitle => 'Hide private details';

  @override
  String get redactHint =>
      'Drag your finger over names, addresses, consumer and meter numbers. Each one is covered with a black box, and only the covered photo is sent.';

  @override
  String get redactKeepVisible => 'Keep units, amounts and dates visible.';

  @override
  String get redactNothing => 'Nothing private on the photo? Just continue.';

  @override
  String get redactSend => 'Read this bill';

  @override
  String get redactPreparing => 'Covering the details…';

  @override
  String redactAreas(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString areas covered',
      one: '1 area covered',
      zero: 'No areas covered',
    );
    return '$_temp0';
  }
}
