// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Currency Converter';

  @override
  String get enterValue => 'Amount in Colombian pesos (COP)';

  @override
  String get selectCurrencies => 'Select currencies to convert:';

  @override
  String get convert => 'Convert';

  @override
  String get enterNumber => 'Enter a valid number';

  @override
  String get enterValuePrompt => 'Enter a value';

  @override
  String get noInternet => 'No Internet connection. The value shown may not be up to date.';
}
