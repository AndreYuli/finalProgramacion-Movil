import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyRepository {
  final String apiKey;
  final String baseCurrency;

  CurrencyRepository({required this.apiKey, this.baseCurrency = 'COP'});

  Future<Map<String, double>> fetchRates(List<String> currencies) async {
    final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['conversion_rates'] as Map<String, dynamic>;
      return {
        for (var c in currencies)
          c: (rates[c] as num?)?.toDouble() ?? 0.0
      };
    } else {
      throw Exception('Error al obtener tasas');
    }
  }
}