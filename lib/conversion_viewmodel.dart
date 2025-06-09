import 'package:flutter/material.dart'; // Importa Flutter para widgets y gestión de estado.
import 'package:connectivity_plus/connectivity_plus.dart'; // Permite verificar la conectividad a internet.
import 'currency_repository.dart'; // Importa el repositorio para obtener tasas de cambio.

// ViewModel que gestiona la lógica de conversión y el estado de la interfaz.
class ConversionViewModel extends ChangeNotifier {
  final CurrencyRepository repository; // Repositorio para obtener tasas de cambio.
  bool loading = false; // Indica si está cargando datos.
  bool offline = false; // Indica si está sin conexión.
  Map<String, double> results = {}; // Guarda los resultados de la conversión.

  ConversionViewModel({required this.repository}); // Constructor que recibe el repositorio.

  // Método para realizar la conversión de pesos a las monedas seleccionadas.
  Future<void> convert(double pesos, List<String> selected) async {
    if (selected.isEmpty) return; // Si no hay monedas seleccionadas, no hace nada.
    loading = true; // Indica que está cargando.
    results = {}; // Limpia resultados anteriores.
    offline = false; // Reinicia el estado offline.
    notifyListeners(); // Notifica a la interfaz que hubo cambios.
    try {
      final connectivity = await Connectivity().checkConnectivity(); // Verifica la conexión a internet.
      if (connectivity == ConnectivityResult.none) { // Si no hay conexión:
        offline = true; // Marca como offline.
        // Valores por defecto aproximados para las monedas.
        final defaultRates = {
          'USD': 0.00025,
          'EUR': 0.00023,
          'BRL': 0.0013,
        };
        // Calcula los resultados usando tasas por defecto.
        results = {
          for (var c in selected) c: pesos * (defaultRates[c] ?? 0.0)
        };
      } else {
        // Si hay conexión, obtiene las tasas reales desde el repositorio.
        final rates = await repository.fetchRates(selected);
        results = {
          for (var c in selected) c: pesos * (rates[c] ?? 0.0)
        };
      }
    } catch (_) {
      results = {}; // Si ocurre un error, limpia los resultados.
    }
    loading = false; // Termina la carga.
    notifyListeners(); // Notifica a la interfaz que hubo cambios.
  }
}

// Widget de ejemplo que muestra cómo usar el ViewModel (puedes ignorar si solo te interesa la lógica).
class ConversionPage extends StatelessWidget {
  final ConversionViewModel _viewModel;

  ConversionPage(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_viewModel.offline)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'No internet connection',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}