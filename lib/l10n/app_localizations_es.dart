// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get title => 'Conversor de Divisas';

  @override
  String get enterValue => 'Ingrese el valor en COP';

  @override
  String get selectCurrencies => 'Seleccione las monedas a convertir';

  @override
  String get convert => 'Convertir';

  @override
  String get enterNumber => 'Debe ingresar un número válido';

  @override
  String get enterValuePrompt => 'Por favor, ingrese un valor';

  @override
  String get noInternet => 'Sin conexión a Internet. El valor mostrado podría no estar actualizado.';

  String get selectAtLeastOneCurrency => 'Seleccione al menos una moneda';
}
