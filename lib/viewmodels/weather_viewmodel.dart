import 'package:flutter/foundation.dart';

import '../data/models/city_location.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/weather_api_service.dart';

enum ViewStatus { loading, success, empty, error }

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._repo);
  final WeatherRepository _repo;

  static const defaultCity = CityLocation(
    name: 'Jakarta',
    admin1: 'DKI Jakarta',
    country: 'Indonesia',
    latitude: -6.2146,
    longitude: 106.8451,
  );

  ViewStatus _status = ViewStatus.loading;
  CityLocation _city = defaultCity;
  WeatherData? _weather;
  String _error = '';
  int _requestId = 0;

  ViewStatus get status => _status;
  CityLocation get city => _city;
  WeatherData? get weather => _weather;
  String get errorMessage => _error;

  Future<void> init() async {
    _city = _repo.getLastCity() ?? defaultCity;
    await _load();
  }

  Future<void> selectCity(CityLocation city) async {
    _city = city;
    await _repo.saveLastCity(city);
    await _load();
  }

  Future<void> refresh() => _load(showLoading: false);

  Future<void> retry() => _load();

  Future<void> _load({bool showLoading = true}) async {
    final id = ++_requestId;
    if (showLoading || _weather == null) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    try {
      final data = await _repo.getWeather(_city);
      if (id != _requestId) return; // abaikan respons usang
      _weather = data;
      _status = data.daily.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _error = e.message;
      _status = ViewStatus.error;
    } catch (_) {
      if (id != _requestId) return;
      _error = 'Terjadi kesalahan tak terduga.';
      _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
