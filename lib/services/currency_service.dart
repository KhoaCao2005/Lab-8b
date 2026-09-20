import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exchange_rate.dart';

class CurrencyService {
  static const String baseUrl = 'https://api.frankfurter.dev/v2';
  Future<ExchangeRate> fetchExchangeRate({
    required String from,
    required String to,
  }) async {
    if (from == to) {
      return ExchangeRate(
        baseCurrency: from,
        targetCurrency: to,
        rate: 1.0,
        date: DateTime.now(),
      );
    }
    final uri = Uri.parse(
      '$baseUrl/rate/${from.toLowerCase()}/${to.toLowerCase()}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load exchange rate. '
        'Status: ${response.statusCode}',
      );
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    return ExchangeRate.fromJson(data, baseCurrency: from, targetCurrency: to);
  }
}
