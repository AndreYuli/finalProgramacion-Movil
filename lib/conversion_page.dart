import 'package:flutter/material.dart'; // Importa Flutter para la interfaz.
import 'package:connectivity_plus/connectivity_plus.dart'; // Permite verificar la conectividad a internet.
import 'l10n/app_localizations.dart'; // Importa las traducciones.
import 'conversion_viewmodel.dart'; // Importa el ViewModel de conversión.
import 'currency_repository.dart'; // Importa el repositorio de monedas.

// Widget principal de la página de conversión.
class ConversionPage extends StatefulWidget {
  final void Function(String)? onLocaleChange; // Callback para cambiar el idioma.
  const ConversionPage({Key? key, this.onLocaleChange}) : super(key: key);

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

// Estado de la página de conversión.
class _ConversionPageState extends State<ConversionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Llave para el formulario.
  final TextEditingController _pesosController = TextEditingController(); // Controlador para el campo de texto de pesos.
  final List<String> _currencies = ['USD', 'EUR', 'BRL']; // Monedas disponibles.
  List<String> _selectedCurrencies = []; // Monedas seleccionadas por el usuario.

  late final ConversionViewModel _viewModel; // ViewModel para manejar la lógica.
  double? _lastConvertedAmount; // Última cantidad convertida.

  @override
  void initState() {
    super.initState();
    // Inicializa el ViewModel con el repositorio y la API key.
    _viewModel = ConversionViewModel(
      repository: CurrencyRepository(apiKey: '041ab2c42d648f6301e7c07d'),
    );
    _viewModel.addListener(_onViewModelChanged); // Escucha cambios en el ViewModel.

    // Verifica la conexión a internet después de construir el widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetAndShowWarning();
    });
  }

  @override
  void dispose() {
    _pesosController.dispose(); // Libera el controlador de texto.
    _viewModel.removeListener(_onViewModelChanged); // Deja de escuchar cambios.
    super.dispose();
  }

  // Se llama cuando el ViewModel cambia.
  void _onViewModelChanged() {
    setState(() {}); // Actualiza la interfaz.
    // Si está offline y hay resultados, muestra un aviso.
    if (_viewModel.offline && _viewModel.results.isNotEmpty) {
      _showNoInternetSnackBar();
    }
  }

  // Verifica la conexión a internet y muestra advertencia si no hay.
  Future<void> _checkInternetAndShowWarning() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetSnackBar();
    }
  }

  // Muestra un mensaje de advertencia si no hay internet.
  void _showNoInternetSnackBar() {
    final s = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.noInternet),
        duration: Duration(seconds: 4),
      ),
    );
  }

  // Realiza la conversión cuando el usuario presiona el botón.
  void _convert() {
    final s = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) { // Valida el formulario.
      if (_selectedCurrencies.isEmpty) { // Si no hay monedas seleccionadas, muestra aviso.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.selectCurrencies)),
        );
        return;
      }
      final pesos = double.parse(_pesosController.text); // Obtiene el valor ingresado.
      _lastConvertedAmount = pesos; // Guarda la cantidad convertida.
      _viewModel.convert(pesos, _selectedCurrencies); // Llama al ViewModel para convertir.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!; // Traducciones.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo, // Color del AppBar.
        title: Text(s.title, style: TextStyle(color: Colors.white)), // Título traducido.
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Tooltip(
              message: s.selectCurrencies,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.language, color: Colors.amber, size: 32), // Icono para cambiar idioma.
                onSelected: (value) {
                  if (widget.onLocaleChange != null) {
                    widget.onLocaleChange!(value); // Cambia el idioma.
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'es', child: Text('Español')),
                  PopupMenuItem(value: 'en', child: Text('English')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Llave del formulario.
          child: Column(
            children: [
              // Campo para ingresar la cantidad en pesos.
              TextFormField(
                controller: _pesosController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: s.enterValue),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return s.enterValuePrompt;
                  }
                  if (double.tryParse(value) == null) {
                    return s.enterNumber;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  s.selectCurrencies,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Lista de monedas con checkbox para seleccionar.
              ..._currencies.map((currency) => CheckboxListTile(
                    title: Text(currency),
                    value: _selectedCurrencies.contains(currency),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedCurrencies.add(currency);
                        } else {
                          _selectedCurrencies.remove(currency);
                        }
                      });
                    },
                  )),
              SizedBox(height: 16),
              // Botón para convertir.
              OutlinedButton.icon(
                icon: Icon(Icons.swap_horiz),
                label: Text(s.convert),
                onPressed: _viewModel.loading ? null : _convert,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: BorderSide(color: Colors.indigo),
                  textStyle: TextStyle(fontSize: 18),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 24),
              // Indicador de carga.
              if (_viewModel.loading) CircularProgressIndicator(),
              // Muestra los resultados de la conversión.
              if (_viewModel.results.isNotEmpty && _lastConvertedAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _viewModel.results.entries
                      .map(
                        (entry) => Text(
                          '${_lastConvertedAmount!.toStringAsFixed(2)} COP = '
                          '${entry.value.toStringAsFixed(2)} ${entry.key}',
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
