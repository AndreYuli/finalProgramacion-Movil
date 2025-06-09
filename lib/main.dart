import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conversion_page.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'es';
  runApp(MainApp(localeCode: localeCode));
}

class MainApp extends StatefulWidget {
  final String localeCode;
  const MainApp({super.key, required this.localeCode});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.localeCode);
  }

  void _changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    setState(() {
      _locale = Locale(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ConversionPage(onLocaleChange: _changeLocale),
      debugShowCheckedModeBanner: false,
    );
  }
}
