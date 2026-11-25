import 'package:flutter/material.dart';

enum WeatherCategory { clear, cloudy, fog, rain, snow, storm }

class WeatherInfo {
  final String label;
  final IconData dayIcon;
  final IconData nightIcon;
  final WeatherCategory category;
  const WeatherInfo(this.label, this.dayIcon, this.nightIcon, this.category);

  IconData icon(bool isDay) => isDay ? dayIcon : nightIcon;
}

/// Menerjemahkan WMO weather code (Open-Meteo) menjadi teks, ikon, dan warna.
class WeatherCode {
  WeatherCode._();

  static const _clear = WeatherInfo('Cerah', Icons.wb_sunny_rounded,
      Icons.nightlight_round, WeatherCategory.clear);
  static const _fewClouds = WeatherInfo('Cerah Berawan', Icons.wb_sunny_rounded,
      Icons.nightlight_round, WeatherCategory.clear);
  static const _partly = WeatherInfo('Berawan Sebagian', Icons.wb_cloudy_rounded,
      Icons.cloud_rounded, WeatherCategory.cloudy);
  static const _overcast = WeatherInfo(
      'Mendung', Icons.cloud_rounded, Icons.cloud_rounded, WeatherCategory.cloudy);
  static const _fog =
      WeatherInfo('Berkabut', Icons.foggy, Icons.foggy, WeatherCategory.fog);
  static const _drizzle = WeatherInfo('Gerimis', Icons.grain_rounded,
      Icons.grain_rounded, WeatherCategory.rain);
  static const _rainLight = WeatherInfo('Hujan Ringan',
      Icons.water_drop_rounded, Icons.water_drop_rounded, WeatherCategory.rain);
  static const _rainMid = WeatherInfo('Hujan Sedang', Icons.water_drop_rounded,
      Icons.water_drop_rounded, WeatherCategory.rain);
  static const _rainHeavy = WeatherInfo('Hujan Lebat', Icons.umbrella_rounded,
      Icons.umbrella_rounded, WeatherCategory.rain);
  static const _showers = WeatherInfo('Hujan Lokal', Icons.umbrella_rounded,
      Icons.umbrella_rounded, WeatherCategory.rain);
  static const _snow = WeatherInfo('Salju', Icons.ac_unit_rounded,
      Icons.ac_unit_rounded, WeatherCategory.snow);
  static const _storm = WeatherInfo('Badai Petir', Icons.thunderstorm_rounded,
      Icons.thunderstorm_rounded, WeatherCategory.storm);
  static const _unknown = WeatherInfo('Tidak Diketahui',
      Icons.help_outline_rounded, Icons.help_outline_rounded, WeatherCategory.cloudy);

  static WeatherInfo describe(int code) {
    switch (code) {
      case 0:
        return _clear;
      case 1:
        return _fewClouds;
      case 2:
        return _partly;
      case 3:
        return _overcast;
      case 45:
      case 48:
        return _fog;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return _drizzle;
      case 61:
        return _rainLight;
      case 63:
        return _rainMid;
      case 65:
      case 66:
      case 67:
        return _rainHeavy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return _snow;
      case 80:
      case 81:
      case 82:
        return _showers;
      case 95:
      case 96:
      case 99:
        return _storm;
      default:
        return _unknown;
    }
  }

  /// Gradien kartu utama mengikuti kondisi cuaca & siang/malam.
  static List<Color> gradient(WeatherCategory c, bool isDay) {
    if (!isDay && (c == WeatherCategory.clear || c == WeatherCategory.cloudy)) {
      return const [Color(0xFF0F172A), Color(0xFF312E81)];
    }
    switch (c) {
      case WeatherCategory.clear:
        return const [Color(0xFF1D4ED8), Color(0xFF38BDF8)];
      case WeatherCategory.cloudy:
        return const [Color(0xFF334155), Color(0xFF64748B)];
      case WeatherCategory.fog:
        return const [Color(0xFF475569), Color(0xFF94A3B8)];
      case WeatherCategory.rain:
        return const [Color(0xFF1E3A8A), Color(0xFF3B82F6)];
      case WeatherCategory.snow:
        return const [Color(0xFF0369A1), Color(0xFF7DD3FC)];
      case WeatherCategory.storm:
        return const [Color(0xFF1E1B4B), Color(0xFF6D28D9)];
    }
  }
}
