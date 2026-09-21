import 'package:flutter/material.dart';

import '../models/exchange_rate.dart';
import '../services/currency_service.dart';
import 'home_screen.dart';

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
  Future<double>? _averageRateFuture;

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

      _averageRateFuture = _currencyService.fetchAverageRate(
        from: _fromCurrency,
        to: _toCurrency,
        days: 30,
      );
    });
  }

  void _swapCurrencies() {
    setState(() {
      final oldFrom = _fromCurrency;

      _fromCurrency = _toCurrency;
      _toCurrency = oldFrom;

      _rateFuture = null;
      _averageRateFuture = null;
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF425363), Color(0xFF26323D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConverterPanel(),
                      const SizedBox(height: 20),
                      if (_rateFuture != null)
                        FutureBuilder<ExchangeRate>(
                          future: _rateFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return _buildError(snapshot.error);
                            }

                            if (!snapshot.hasData) {
                              return _buildEmptyResult();
                            }

                            final rate = snapshot.data!;
                            final convertedAmount = rate.convert(_amount);

                            return FutureBuilder<double>(
                              future: _averageRateFuture,
                              builder: (context, averageSnapshot) {
                                return _buildResult(
                                  rate,
                                  convertedAmount,
                                  averageSnapshot,
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.currency_exchange, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          const Text(
            'Currency Helper',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONVERTER PANEL
  // ============================================================

  Widget _buildConverterPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A6B7C), Color(0xFF323B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Currency Converter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Convert money using the latest available exchange rate from Frankfurter.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),

          _buildFieldLabel('Amount'),

          const SizedBox(height: 6),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Color(0xFF1E4663),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: const TextStyle(
                color: Color(0xFF8A9298),
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Color(0xFF5A6B7C),
              ),
              filled: true,
              fillColor: const Color(0xFFFDFBF7),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF521B),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrencyField(
                      label: 'From',
                      value: _fromCurrency,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _fromCurrency = value;
                          _rateFuture = null;
                          _averageRateFuture = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: IconButton.filled(
                        onPressed: _swapCurrencies,
                        icon: const Icon(Icons.swap_vert),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFF521B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCurrencyField(
                      label: 'To',
                      value: _toCurrency,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _toCurrency = value;
                          _rateFuture = null;
                          _averageRateFuture = null;
                        });
                      },
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildCurrencyField(
                      label: 'From',
                      value: _fromCurrency,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _fromCurrency = value;
                          _rateFuture = null;
                          _averageRateFuture = null;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: IconButton.filled(
                        onPressed: _swapCurrencies,
                        icon: const Icon(Icons.swap_horiz),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFF521B),
                          foregroundColor: Colors.white,
                          fixedSize: const Size(48, 48),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildCurrencyField(
                      label: 'To',
                      value: _toCurrency,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _toCurrency = value;
                          _rateFuture = null;
                          _averageRateFuture = null;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.currency_exchange),
              label: const Text(
                'Convert',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF521B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // CURRENCY FIELD
  // ============================================================

  Widget _buildCurrencyField({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: const Color(0xFFFDFBF7),
          style: const TextStyle(
            color: Color(0xFF1E4663),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFDFBF7),
            prefixIcon: const Icon(
              Icons.monetization_on_outlined,
              color: Color(0xFF5A6B7C),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF521B), width: 2),
            ),
          ),
          items: _currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
                style: const TextStyle(
                  color: Color(0xFF1E4663),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ============================================================
  // RESULT
  // ============================================================

  Widget _buildResult(
    ExchangeRate rate,
    double convertedAmount,
    AsyncSnapshot<double> averageSnapshot,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF5A6B7C)),
              SizedBox(width: 8),
              Text(
                'Conversion Result',
                style: TextStyle(
                  color: Color(0xFF1E4663),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            '${_formatNumber(_amount)} ${rate.baseCurrency}',
            style: const TextStyle(color: Color(0xFF5A6B7C), fontSize: 17),
          ),

          const SizedBox(height: 8),

          Text(
            '≈ ${_formatNumber(convertedAmount)} ${rate.targetCurrency}',
            style: const TextStyle(
              color: Color(0xFF1E4663),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            'Exchange rate',
            '1 ${rate.baseCurrency} = '
                '${rate.rate.toStringAsFixed(6)} '
                '${rate.targetCurrency}',
          ),

          const SizedBox(height: 8),

          _buildInfoRow(
            'Rate date',
            rate.date.toIso8601String().substring(0, 10),
          ),

          const SizedBox(height: 8),

          if (averageSnapshot.connectionState == ConnectionState.waiting)
            _buildAverageLoading()
          else if (averageSnapshot.hasData)
            _buildRateHint(rate.rate, averageSnapshot.data!)
          else
            _buildHintUnavailable(),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF5A6B7C).withOpacity(0.10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF5A6B7C)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Use this result as a quick reference for travel, shopping, or basic currency comparison.',
                    style: TextStyle(color: Color(0xFF5A6B7C)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RATE HINT
  // ============================================================

  Widget _buildRateHint(double currentRate, double averageRate) {
    final differencePercent = ((currentRate - averageRate) / averageRate) * 100;

    String title;
    String message;
    IconData icon;

    if (differencePercent > 1) {
      title = 'Rate is higher than average';
      message =
          'The current rate is ${differencePercent.abs().toStringAsFixed(1)}% '
          'above the 30-day average.';
      icon = Icons.trending_up;
    } else if (differencePercent < -1) {
      title = 'Rate is lower than average';
      message =
          'The current rate is ${differencePercent.abs().toStringAsFixed(1)}% '
          'below the 30-day average.';
      icon = Icons.trending_down;
    } else {
      title = 'Rate is close to average';
      message = 'The current rate is within 1% of the 30-day average.';
      icon = Icons.trending_flat;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF5A6B7C).withOpacity(0.10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5A6B7C)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E4663),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Color(0xFF5A6B7C), height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  '30-day average: ${averageRate.toStringAsFixed(6)} '
                  '${_toCurrency}',
                  style: const TextStyle(
                    color: Color(0xFF5A6B7C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVERAGE LOADING
  // ============================================================

  Widget _buildAverageLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF5A6B7C).withOpacity(0.10),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF5A6B7C),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Checking the current rate against the 30-day average...',
              style: TextStyle(color: Color(0xFF5A6B7C)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HINT UNAVAILABLE
  // ============================================================

  Widget _buildHintUnavailable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF5A6B7C).withOpacity(0.10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF5A6B7C)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Historical rate data is currently unavailable, so no rate hint can be calculated.',
              style: TextStyle(color: Color(0xFF5A6B7C), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A6B7C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E4663),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(Object? error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 50, color: Color(0xFFFF521B)),

          const SizedBox(height: 12),

          const Text(
            'Unable to get exchange rate.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1E4663),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5A6B7C)),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF521B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY RESULT
  // ============================================================

  Widget _buildEmptyResult() {
    return const Center(
      child: Text(
        'No exchange rate available.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }
}
