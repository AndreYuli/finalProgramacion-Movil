import 'package:http/http.dart' as http; // Importa la librería http para hacer peticiones a APIs.
import 'dart:convert'; // Importa funciones para convertir datos JSON.

// Clase que se encarga de obtener tasas de cambio de monedas desde una API.
class CurrencyRepository {
  final String apiKey; // Clave de acceso para la API de tasas de cambio.
  final String baseCurrency; // Moneda base para las conversiones.

  // Constructor que recibe la apiKey y opcionalmente la moneda base (por defecto 'COP').
  CurrencyRepository({required this.apiKey, this.baseCurrency = 'COP'});

  // Método para obtener las tasas de cambio de una lista de monedas.
  Future<Map<String, double>> fetchRates(List<String> currencies) async {
    // Construye la URL para la petición a la API usando la apiKey y la moneda base.
    final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency');
    // Realiza la petición GET a la API.
    final response = await http.get(url);
    // Si la respuesta es exitosa (código 200):
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica el JSON recibido.
      final rates = data['conversion_rates'] as Map<String, dynamic>; // Extrae las tasas de cambio.
      // Retorna un mapa con las tasas solicitadas, convirtiendo a double o 0.0 si no existe.
      return {
        for (var c in currencies)
          c: (rates[c] as num?)?.toDouble() ?? 0.0
      };
    } else {
      // Si ocurre un error, lanza una excepción.
      throw Exception('Error al obtener tasas');
    }
  }
}