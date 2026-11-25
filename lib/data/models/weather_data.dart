double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _i(dynamic v) => (v as num?)?.round() ?? 0;

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        time: DateTime.parse(j['time'] as String),
        temperature: _d(j['temperature_2m']),
        humidity: _i(j['relative_humidity_2m']),
        apparentTemperature: _d(j['apparent_temperature']),
        precipitation: _d(j['precipitation']),
        weatherCode: _i(j['weather_code']),
        windSpeed: _d(j['wind_speed_10m']),
        isDay: _i(j['is_day']) == 1,
      );
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int rainProbability;
  final DateTime? sunrise;
  final DateTime? sunset;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.rainProbability,
    this.sunrise,
    this.sunset,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int rainProbability;
  final int weatherCode;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.rainProbability,
    required this.weatherCode,
  });

  bool get isDay => time.hour >= 6 && time.hour < 18;
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  const WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
  });

  DailyForecast? get today => daily.isEmpty ? null : daily.first;

  /// Mengubah respons JSON Open-Meteo menjadi model Dart.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current =
        CurrentWeather.fromJson(json['current'] as Map<String, dynamic>);

    final d = json['daily'] as Map<String, dynamic>;
    final dTimes = (d['time'] as List).cast<String>();
    final daily = <DailyForecast>[
      for (var i = 0; i < dTimes.length; i++)
        DailyForecast(
          date: DateTime.parse(dTimes[i]),
          weatherCode: _i((d['weather_code'] as List)[i]),
          tempMax: _d((d['temperature_2m_max'] as List)[i]),
          tempMin: _d((d['temperature_2m_min'] as List)[i]),
          rainProbability: _i((d['precipitation_probability_max'] as List)[i]),
          sunrise: d['sunrise'] == null
              ? null
              : DateTime.tryParse((d['sunrise'] as List)[i] as String),
          sunset: d['sunset'] == null
              ? null
              : DateTime.tryParse((d['sunset'] as List)[i] as String),
        ),
    ];

    final hourly = <HourlyForecast>[];
    final h = json['hourly'] as Map<String, dynamic>?;
    if (h != null) {
      final hTimes = (h['time'] as List).cast<String>();
      final startHour = DateTime(current.time.year, current.time.month,
          current.time.day, current.time.hour);
      for (var i = 0; i < hTimes.length; i++) {
        final t = DateTime.parse(hTimes[i]);
        if (t.isBefore(startHour)) continue;
        hourly.add(HourlyForecast(
          time: t,
          temperature: _d((h['temperature_2m'] as List)[i]),
          rainProbability: _i((h['precipitation_probability'] as List)[i]),
          weatherCode: _i((h['weather_code'] as List)[i]),
        ));
        if (hourly.length == 24) break;
      }
    }

    return WeatherData(current: current, daily: daily, hourly: hourly);
  }
}
