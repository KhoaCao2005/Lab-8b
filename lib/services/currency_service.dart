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

  Future<double> fetchAverageRate({
    required String from,
    required String to,
    int days = 30,
  }) async {
    if (from == to) {
      return 1.0;
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final fromDate = _formatDate(startDate);
    final toDate = _formatDate(now);

    final uri = Uri.parse(
      '$baseUrl/rates?from=$fromDate&to=$toDate'
      '&base=${from.toLowerCase()}'
      '&quotes=${to.toLowerCase()}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load historical exchange rates. '
        'Status: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    if (data.isEmpty) {
      throw Exception('No historical exchange rate data available.');
    }

    double total = 0;
    int count = 0;

    for (final item in data) {
      final rate = (item['rate'] ?? 0).toDouble();

      if (rate > 0) {
        total += rate;
        count++;
      }
    }

    if (count == 0) {
      throw Exception('No valid historical exchange rate data available.');
    }

    return total / count;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
