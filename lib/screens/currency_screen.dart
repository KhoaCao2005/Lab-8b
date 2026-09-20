import 'package:flutter/material.dart';

import '../models/exchange_rate.dart';
import '../services/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final List<String> _currencies = [
    'USD',
    'VND',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
  ];
  String _fromCurrency = 'USD';
  String _toCurrency = 'VND';
  Future<ExchangeRate>? _rateFuture;
  double get _amount {
    return double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than 0.')),
      );
      return;
    }
    setState(() {
      _rateFuture = _currencyService.fetchExchangeRate(
        from: _fromCurrency,
        to: _toCurrency,
      );
    });
  }

  void _swapCurrencies() {
    setState(() {
      final oldFrom = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = oldFrom;
      _rateFuture = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💱 Currency Helper')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency Converter',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Convert money using the latest available '
              'exchange rate from Frankfurter.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _currencyDropdown(
                    label: 'From',
                    value: _fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                        _rateFuture = null;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: _swapCurrencies,
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ),
                Expanded(
                  child: _currencyDropdown(
                    label: 'To',
                    value: _toCurrency,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                        _rateFuture = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _convert,
                icon: const Icon(Icons.currency_exchange),
                label: const Text('Convert'),
              ),
            ),
            const SizedBox(height: 30),
            if (_rateFuture != null)
              FutureBuilder<ExchangeRate>(
                future: _rateFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error);
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No exchange rate available.'),
                    );
                  }
                  final rate = snapshot.data!;
                  final convertedAmount = rate.convert(_amount);
                  return _buildResult(rate, convertedAmount);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _currencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: _currencies.map((currency) {
        return DropdownMenuItem(value: currency, child: Text(currency));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResult(ExchangeRate rate, double convertedAmount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '${_formatNumber(_amount)} '
              '${rate.baseCurrency}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '≈ ${_formatNumber(convertedAmount)} '
              '${rate.targetCurrency}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '1 ${rate.baseCurrency} = '
              '${rate.rate.toStringAsFixed(6)} '
              '${rate.targetCurrency}',
            ),
            const SizedBox(height: 8),
            Text(
              'Rate date: '
              '${rate.date.toIso8601String().substring(0, 10)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.withOpacity(0.08),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use this result as a quick reference '
                      'for travel, shopping, or basic currency '
                      'comparison.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 50),
            const SizedBox(height: 12),
            const Text(
              'Unable to get exchange rate.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }
}
