import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final LayerLink _layerLink = LayerLink();
  final ScrollController _dailyScrollController = ScrollController();

  Future<WeatherForecast>? _weatherFuture;
  bool _isCelsius = true;
  int _selectedDayIndex = 0;

  List<CityLocation> _searchResults = [];
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cityController.text = 'London';
    _searchWeather('London');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _cityController.dispose();
    _dailyScrollController.dispose();
    super.dispose();
  }

  void _searchWeather(String city, {bool hideKeyboard = false}) {
    _removeOverlay();

    if (hideKeyboard) {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      _selectedDayIndex = 0;
      _weatherFuture = _weatherService.fetchWeatherAndForecast(city);
    });
  }

  void _selectCityLocation(CityLocation location) {
    _removeOverlay();
    _cityController.text = location.name;
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedDayIndex = 0;
      _weatherFuture = _weatherService.fetchWeatherByCoords(
        location.lat,
        location.lon,
        cityName: location.name,
        country: location.country,
      );
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        _removeOverlay();
        return;
      }
      final results = await _weatherService.searchCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
        _showOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    if (_searchResults.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 320,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 48),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF2B2B30),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final city = _searchResults[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    city.subtitleLocation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    city.formattedCoords,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () => _selectCityLocation(city),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _formatTemp(double temp) {
    if (!_isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  String _windDirection(int deg) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((deg + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Groups forecast entries by date and selects up to 8 days (Today + 7 days).
  /// Chooses midday entries (~12:00 PM) for accurate daytime weather icons.
  List<ForecastItem> _getDailyForecast(
    List<ForecastItem> hourly,
    int timezoneOffset,
  ) {
    final Map<String, List<ForecastItem>> grouped = {};
    for (var item in hourly) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        item.dt * 1000,
        isUtc: true,
      ).add(Duration(seconds: timezoneOffset));
      final dayStr = DateFormat('yyyy-MM-dd').format(date);
      grouped.putIfAbsent(dayStr, () => []).add(item);
    }

    final List<ForecastItem> result = [];
    grouped.forEach((dayStr, items) {
      ForecastItem bestItem = items.first;
      int minDiff = 24;
      for (var item in items) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          item.dt * 1000,
          isUtc: true,
        ).add(Duration(seconds: timezoneOffset));
        int diff = (date.hour - 12).abs();
        if (diff < minDiff) {
          minDiff = diff;
          bestItem = item;
        }
      }
      result.add(bestItem);
    });

    return result.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeOverlay,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF425363), Color(0xFF26323D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FutureBuilder<WeatherForecast>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                final currentCity = snapshot.hasData
                    ? '${snapshot.data!.current.cityName}, ${snapshot.data!.current.country}'
                    : 'Location';

                return Column(
                  children: [
                    _buildTopBar(currentCity),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error}',
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return _buildDashboard(snapshot.data!);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String locationText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Weather forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildUnitToggle(),
            ],
          ),
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    locationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              CompositedTransformTarget(
                link: _layerLink,
                child: SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _cityController,
                    onChanged: _onSearchChanged,
                    onSubmitted: (val) =>
                        _searchWeather(val, hideKeyboard: true),
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search City',
                      filled: true,
                      fillColor: const Color(0xFFFDFBF7),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitBtn('°C', _isCelsius),
          _buildUnitBtn('°F', !_isCelsius),
        ],
      ),
    );
  }

  Widget _buildUnitBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCelsius = label == '°C';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(WeatherForecast data) {
    final daily = _getDailyForecast(data.hourly, data.timezoneOffset);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyStrip(daily, data.timezoneOffset),
          const SizedBox(height: 20),
          _buildMainWeatherPanel(data, daily),
        ],
      ),
    );
  }

  Widget _buildDailyStrip(List<ForecastItem> daily, int timezoneOffset) {
    return Scrollbar(
      controller: _dailyScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _dailyScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: daily.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;

            final date = DateTime.fromMillisecondsSinceEpoch(
              day.dt * 1000,
              isUtc: true,
            ).add(Duration(seconds: timezoneOffset));

            final isSelected = index == _selectedDayIndex;
            final dayName = index == 0
                ? 'Today'
                : DateFormat('EEE').format(date);
            final tempVal = day.temperature.round();

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF521B)
                      : const Color(0xFF3C4C59).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.2),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$tempVal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          '°',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      day.iconUrl,
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMainWeatherPanel(
    WeatherForecast data,
    List<ForecastItem> daily,
  ) {
    final isTodaySelected = _selectedDayIndex == 0;
    final double temp = isTodaySelected
        ? data.current.temperature
        : daily[_selectedDayIndex].temperature;
    final double feelsLike = isTodaySelected
        ? data.current.feelsLike
        : daily[_selectedDayIndex].feelsLike;
    final String description = isTodaySelected
        ? data.current.description
        : daily[_selectedDayIndex].description;

    final cityTime = DateTime.now().toUtc().add(
      Duration(seconds: data.timezoneOffset),
    );

    final item = isTodaySelected ? null : daily[_selectedDayIndex];

    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF5A6B7C), Color(0xFF323B44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  DateFormat('h:mm a').format(cityTime),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTemp(temp),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _toTitleCase(description),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Feels like ${_formatTemp(feelsLike)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 400 ? 2 : 3;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildDetailCard(
                  Icons.air,
                  'Wind',
                  '${(item?.windSpeed ?? data.current.windSpeed).round()} m/s ${_windDirection(item?.windDeg ?? data.current.windDeg)}',
                ),
                _buildDetailCard(
                  Icons.water_drop_outlined,
                  'Humidity',
                  '${item?.humidity ?? data.current.humidity}%',
                ),
                _buildDetailCard(
                  Icons.visibility_outlined,
                  'Visibility',
                  '${(item?.visibility ?? data.current.visibility) / 1000}km',
                ),
                _buildDetailCard(
                  Icons.compress,
                  'Pressure',
                  '${item?.pressure ?? data.current.pressure} hPa',
                ),
                _buildDetailCard(
                  Icons.wb_sunny_outlined,
                  'UV Index',
                  '${data.current.uvIndex.round()} UV',
                ),
                _buildDetailCard(
                  Icons.water_drop_outlined,
                  'Dew Point',
                  '${_formatTemp(data.current.dewPoint)}${_isCelsius ? "C" : "F"}',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF5A6B7C)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF5A6B7C), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E4663),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
