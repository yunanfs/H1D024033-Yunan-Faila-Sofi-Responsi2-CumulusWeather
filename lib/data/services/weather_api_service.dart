import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city_location.dart';
import '../models/weather_data.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Semua HTTP GET ke Open-Meteo (Geocoding + Forecast) ada di sini.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<CityLocation>> searchCities(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });
    final json = await _get(uri);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((e) => CityLocation.fromGeocoding(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherData> getWeather(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m,is_day',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _get(uri);
    try {
      return WeatherData.fromJson(json);
    } catch (_) {
      throw ApiException('Format data cuaca dari server tidak sesuai.');
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw ApiException('Server mengembalikan kode ${res.statusCode}.');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Permintaan melebihi batas waktu. Coba lagi.');
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    } catch (_) {
      throw ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }
}
