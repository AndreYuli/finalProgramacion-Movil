import 'package:flutter/material.dart';
import 'package:cambio/generated/l10n.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = ConversionViewModel(
      repository: CurrencyRepository(
        apiKey: '041ab2c42d648f6301e7c07d',
      ),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _pesosController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  void _convert() {
    if (_formKey.currentState!.validate() && _selectedCurrencies.isNotEmpty) {
      final pesos = double.parse(_pesosController.text);
      _viewModel.convert(pesos, _selectedCurrencies);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
        actions: [
          DropdownButton<String>(
            value: Localizations.localeOf(context).languageCode,
            items: [
              DropdownMenuItem(value: 'es', child: Text('ES')),
              DropdownMenuItem(value: 'en', child: Text('EN')),
            ],
            onChanged: (value) {
              if (value != null && widget.onLocaleChange != null) {
                widget.onLocaleChange!(value);
              }
            },
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
                child: Text(s.selectCurrencies, style: TextStyle(fontWeight: FontWeight.bold)),
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
              ElevatedButton(
                onPressed: _viewModel.loading ? null : _convert,
                child: Text(s.convert),
              ),
              SizedBox(height: 24),
              if (_viewModel.loading) CircularProgressIndicator(),
              if (_viewModel.results.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _viewModel.results.entries
                      .map((entry) => Text(
                          '${_pesosController.text} COP = ${entry.value.toStringAsFixed(2)} ${entry.key}'))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}