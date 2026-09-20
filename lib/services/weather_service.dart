import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  Future<WeatherForecast> fetchWeatherAndForecast(String query) async {
    final cities = await searchCities(query);
    if (cities.isEmpty) {
      throw Exception('City not found: $query');
    }

    final city = cities.first;
    return fetchWeatherByCoords(
      city.lat,
      city.lon,
      cityName: city.name,
      country: city.country,
    );
  }

  Future<WeatherForecast> fetchWeatherByCoords(
    double lat,
    double lon, {
    String cityName = '',
    String country = '',
  }) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,pressure_msl,wind_speed_10m,wind_direction_10m,visibility,dew_point_2m,uv_index,weather_code'
      '&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,pressure_msl,wind_speed_10m,wind_direction_10m,visibility,weather_code,precipitation_probability'
      '&timeformat=unixtime'
      '&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final json = jsonDecode(response.body);

    var weather = Weather.fromOpenMeteoJson(
      json,
      city: cityName,
      country: country,
    );
    final timezoneOffset = json['utc_offset_seconds'] as int? ?? 0;

    final hourlyJson = json['hourly'];
    final List<dynamic> times = hourlyJson['time'];
    final List<dynamic> temps = hourlyJson['temperature_2m'];
    final List<dynamic> feelsLike = hourlyJson['apparent_temperature'];
    final List<dynamic> humidities = hourlyJson['relative_humidity_2m'];
    final List<dynamic> windSpeeds = hourlyJson['wind_speed_10m'];
    final List<dynamic> windDegs = hourlyJson['wind_direction_10m'];
    final List<dynamic> visibilities = hourlyJson['visibility'];
    final List<dynamic> pressures = hourlyJson['pressure_msl'];
    final List<dynamic> weatherCodes = hourlyJson['weather_code'];
    final List<dynamic> pops = hourlyJson['precipitation_probability'];

    final List<ForecastItem> hourly = [];

    for (int i = 0; i < times.length; i++) {
      final code = (weatherCodes[i] as num).toInt();
      final cond = _mapWmoCode(code);

      hourly.add(
        ForecastItem(
          dt: (times[i] as num).toInt(),
          temperature: (temps[i] as num).toDouble(),
          feelsLike: (feelsLike[i] as num).toDouble(),
          description: cond['description']!,
          iconCode: cond['icon']!,
          pop: ((pops[i] ?? 0) as num).toDouble() / 100.0,
          humidity: (humidities[i] as num).toInt(),
          windSpeed: (windSpeeds[i] as num).toDouble(),
          windDeg: (windDegs[i] as num).toInt(),
          visibility: (visibilities[i] as num).toInt(),
          pressure: (pressures[i] as num).toInt(),
        ),
      );
    }

    return WeatherForecast(
      current: weather,
      hourly: hourly,
      timezoneOffset: timezoneOffset,
    );
  }

  Future<List<CityLocation>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(query)}'
      '&count=5'
      '&language=en'
      '&format=json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('results')) {
          final List list = json['results'];
          return list.map((e) => CityLocation.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Maps WMO Weather Interpretation Codes to descriptions and icon keys
  Map<String, String> _mapWmoCode(int code) {
    switch (code) {
      case 0:
        return {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'};
      case 1:
        return {'main': 'Clouds', 'description': 'mainly clear', 'icon': '02d'};
      case 2:
        return {
          'main': 'Clouds',
          'description': 'partly cloudy',
          'icon': '03d',
        };
      case 3:
        return {'main': 'Clouds', 'description': 'overcast', 'icon': '04d'};
      case 45:
      case 48:
        return {'main': 'Fog', 'description': 'foggy', 'icon': '50d'};
      case 51:
      case 53:
      case 55:
        return {'main': 'Drizzle', 'description': 'drizzle', 'icon': '09d'};
      case 61:
      case 63:
      case 65:
        return {'main': 'Rain', 'description': 'rain', 'icon': '10d'};
      case 71:
      case 73:
      case 75:
        return {'main': 'Snow', 'description': 'snow', 'icon': '13d'};
      case 80:
      case 81:
      case 82:
        return {'main': 'Rain', 'description': 'rain showers', 'icon': '09d'};
      case 95:
      case 96:
      case 99:
        return {
          'main': 'Thunderstorm',
          'description': 'thunderstorm',
          'icon': '11d',
        };
      default:
        return {'main': 'Clear', 'description': 'clear', 'icon': '01d'};
    }
  }
}
