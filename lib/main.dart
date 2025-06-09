import 'package:flutter/material.dart'; // Importa el paquete principal de Flutter para construir la interfaz.
import 'package:shared_preferences/shared_preferences.dart'; // Permite guardar y recuperar datos localmente.
import 'conversion_page.dart'; // Importa la página principal de conversión.
import 'l10n/app_localizations.dart'; // Importa las configuraciones de localización (traducciones).

// Función principal que inicia la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los widgets estén inicializados antes de ejecutar código asíncrono.
  final prefs = await SharedPreferences.getInstance(); // Obtiene la instancia de preferencias compartidas.
  final localeCode = prefs.getString('locale') ?? 'es'; // Recupera el código de idioma guardado, o usa 'es' (español) por defecto.
  runApp(MainApp(localeCode: localeCode)); // Inicia la app pasando el código de idioma.
}

// Widget principal de la aplicación, con estado para poder cambiar el idioma.
class MainApp extends StatefulWidget {
  final String localeCode; // Código de idioma seleccionado.
  const MainApp({super.key, required this.localeCode}); // Constructor que recibe el código de idioma.

  @override
  State<MainApp> createState() => _MainAppState(); // Crea el estado asociado a este widget.
}

// Estado de MainApp, donde se maneja el idioma y la lógica de cambio de idioma.
class _MainAppState extends State<MainApp> {
  late Locale _locale; // Variable para guardar el idioma actual.

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.localeCode); // Inicializa el idioma con el valor recibido.
  }

  // Método para cambiar el idioma de la app.
  void _changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance(); // Obtiene las preferencias compartidas.
    await prefs.setString('locale', code); // Guarda el nuevo código de idioma.
    setState(() {
      _locale = Locale(code); // Actualiza el estado con el nuevo idioma.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Construye la aplicación principal.
    return MaterialApp(
      locale: _locale, // Establece el idioma actual.
      supportedLocales: AppLocalizations.supportedLocales, // Idiomas soportados.
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Delegados para traducción.
      home: ConversionPage(onLocaleChange: _changeLocale), // Página principal, recibe función para cambiar idioma.
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de debug.
    );
  }
}
