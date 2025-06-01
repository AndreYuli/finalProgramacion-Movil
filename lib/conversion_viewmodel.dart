import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'currency_repository.dart';

class ConversionViewModel extends ChangeNotifier {
  final CurrencyRepository repository;
  bool loading = false;
  bool offline = false;
  Map<String, double> results = {};

  ConversionViewModel({required this.repository});

  Future<void> convert(double pesos, List<String> selected) async {
    if (selected.isEmpty) return;
    loading = true;
    results = {};
    offline = false;
    notifyListeners();
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        offline = true;
        // Valores por defecto aproximados
        final defaultRates = {
          'USD': 0.00025,
          'EUR': 0.00023,
          'BRL': 0.0013,
        };
        results = {
          for (var c in selected) c: pesos * (defaultRates[c] ?? 0.0)
        };
      } else {
        final rates = await repository.fetchRates(selected);
        results = {
          for (var c in selected) c: pesos * (rates[c] ?? 0.0)
        };
      }
    } catch (_) {
      results = {};
    }
    loading = false;
    notifyListeners();
  }
}

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
            // ...existing widgets...
            if (_viewModel.offline)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  S.of(context).noInternet,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            // ...existing widgets...
          ],
        ),
      ),
    );
  }
}