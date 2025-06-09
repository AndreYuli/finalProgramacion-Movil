import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'l10n/app_localizations.dart';
import 'conversion_viewmodel.dart';
import 'currency_repository.dart'; 

class ConversionPage extends StatefulWidget {
  final void Function(String)? onLocaleChange;
  const ConversionPage({Key? key, this.onLocaleChange}) : super(key: key);

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pesosController = TextEditingController();
  final List<String> _currencies = ['USD', 'EUR', 'BRL'];
  List<String> _selectedCurrencies = [];

  late final ConversionViewModel _viewModel;
  double? _lastConvertedAmount;

  @override
  void initState() {
    super.initState();
    _viewModel = ConversionViewModel(
      repository: CurrencyRepository(apiKey: '041ab2c42d648f6301e7c07d'),
    );
    _viewModel.addListener(_onViewModelChanged);

    // Verificar conexión después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetAndShowWarning();
    });
  }

  @override
  void dispose() {
    _pesosController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
    if (_viewModel.offline && _viewModel.results.isNotEmpty) {
      _showNoInternetSnackBar();
    }
  }

  Future<void> _checkInternetAndShowWarning() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetSnackBar();
    }
  }

  void _showNoInternetSnackBar() {
    final s = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.noInternet),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _convert() {
    final s = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_selectedCurrencies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.selectCurrencies)),
        );
        return;
      }
      final pesos = double.parse(_pesosController.text);
      _lastConvertedAmount = pesos;
      _viewModel.convert(pesos, _selectedCurrencies);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo, // Color más visible
        title: Text(s.title, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Tooltip(
              message: s.selectCurrencies,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.language, color: Colors.amber, size: 32), // Más grande y visible
                onSelected: (value) {
                  if (widget.onLocaleChange != null) {
                    widget.onLocaleChange!(value);
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
          key: _formKey,
          child: Column(
            children: [
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
              if (_viewModel.loading) CircularProgressIndicator(),
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
