
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city_location.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kFavorites = 'favorites';
  static const _kHistory = 'search_history';
  static const _kLastCity = 'last_city';

  // Mengambil daftar kota favorit
  List<CityLocation> getFavorites() {
    final data = _prefs.get(_kFavorites);

    if (data == null) return [];

    try {
      List<String> raw;

      if (data is List) {
        raw = data.map((e) => e.toString()).toList();
      } else if (data is String) {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          raw = decoded.map((e) => e.toString()).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }

      final cities = raw.map((e) {
        return CityLocation.fromJson(
          jsonDecode(e) as Map<String, dynamic>,
        );
      }).toList();

      return cities;
    } catch (_) {
      return [];
    }
  }

  // Menyimpan kota favorit
  Future<void> saveFavorites(List<CityLocation> list) async {
    await _prefs.setStringList(
      _kFavorites,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // Mengambil riwayat pencarian
  List<String> getHistory() {
    return _prefs.getStringList(_kHistory) ?? [];
  }

  // Menyimpan riwayat pencarian
  Future<void> saveHistory(List<String> list) async {
    await _prefs.setStringList(_kHistory, list);
  }

  // Mengambil kota terakhir
  CityLocation? getLastCity() {
    final raw = _prefs.getString(_kLastCity);

    if (raw == null) return null;

    try {
      return CityLocation.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // Menyimpan kota terakhir
  Future<void> saveLastCity(CityLocation city) async {
    await _prefs.setString(
      _kLastCity,
      jsonEncode(city.toJson()),
    );
  }
}
