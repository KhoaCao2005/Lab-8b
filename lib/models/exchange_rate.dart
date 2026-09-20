class ExchangeRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime date;
  ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.date,
  });
  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    required String baseCurrency,
    required String targetCurrency,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      rate: (json['rate'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
  double convert(double amount) {
    return amount * rate;
  }
}
