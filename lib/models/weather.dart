class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final String mainCondition;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int visibility;
  final int pressure;
  final int dt;
  final double lat;
  final double lon;
  final double dewPoint;
  final double uvIndex;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.mainCondition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.visibility,
    required this.pressure,
    required this.dt,
    required this.lat,
    required this.lon,
    required this.dewPoint,
    this.uvIndex = 0,
  });

  Weather copyWith({double? uvIndex, String? cityName, String? country}) {
    return Weather(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      temperature: temperature,
      feelsLike: feelsLike,
      description: description,
      mainCondition: mainCondition,
      iconCode: iconCode,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: windDeg,
      visibility: visibility,
      pressure: pressure,
      dt: dt,
      lat: lat,
      lon: lon,
      dewPoint: dewPoint,
      uvIndex: uvIndex ?? this.uvIndex,
    );
  }

  factory Weather.fromOpenMeteoJson(
    Map<String, dynamic> json, {
    String city = '',
    String country = '',
  }) {
    final current = json['current'];
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final conditionInfo = _mapWmoCode(weatherCode);

    final rawTime = current['time'];
    final int dtValue;
    if (rawTime is num) {
      dtValue = rawTime.toInt();
    } else if (rawTime is String) {
      dtValue = DateTime.tryParse(rawTime)?.millisecondsSinceEpoch != null
          ? DateTime.parse(rawTime).millisecondsSinceEpoch ~/ 1000
          : DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      dtValue = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    return Weather(
      cityName: city,
      country: country,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      description: conditionInfo['description']!,
      mainCondition: conditionInfo['main']!,
      iconCode: conditionInfo['icon']!,
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDeg: (current['wind_direction_10m'] as num).toInt(),
      visibility: (current['visibility'] as num).toInt(),
      pressure: (current['pressure_msl'] as num).toInt(),
      dt: dtValue,
      lat: (json['latitude'] as num).toDouble(),
      lon: (json['longitude'] as num).toDouble(),
      dewPoint: (current['dew_point_2m'] as num).toDouble(),
      uvIndex: (current['uv_index'] as num).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class ForecastItem {
  final int dt;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final double pop;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int visibility;
  final int pressure;

  ForecastItem({
    required this.dt,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.pop,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.visibility,
    required this.pressure,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class WeatherForecast {
  final Weather current;
  final List<ForecastItem> hourly;
  final int timezoneOffset;

  WeatherForecast({
    required this.current,
    required this.hourly,
    required this.timezoneOffset,
  });
}

class CityLocation {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String? state;

  CityLocation({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
    this.state,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'] ?? '',
      lat: (json['latitude'] as num).toDouble(),
      lon: (json['longitude'] as num).toDouble(),
      country: json['country'] ?? json['country_code'] ?? '',
      state: json['admin1'],
    );
  }

  String get subtitleLocation =>
      state != null && state!.isNotEmpty ? '$name, $state' : '$name, $country';

  String get formattedCoords =>
      '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
}

Map<String, String> _mapWmoCode(int code) {
  switch (code) {
    case 0:
      return {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'};
    case 1:
      return {'main': 'Clouds', 'description': 'mainly clear', 'icon': '02d'};
    case 2:
      return {'main': 'Clouds', 'description': 'partly cloudy', 'icon': '03d'};
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
