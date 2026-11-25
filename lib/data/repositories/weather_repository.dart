import '../models/city_location.dart';
import '../models/weather_data.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Satu pintu data untuk ViewModel: API (remote) + storage (local).
class WeatherRepository {
  WeatherRepository(this._api, this._storage);
  final WeatherApiService _api;
  final LocalStorageService _storage;

  Future<List<CityLocation>> searchCities(String q) => _api.searchCities(q);

  Future<WeatherData> getWeather(CityLocation c) =>
      _api.getWeather(c.latitude, c.longitude);

  List<CityLocation> getFavorites() => _storage.getFavorites();
  Future<void> saveFavorites(List<CityLocation> l) => _storage.saveFavorites(l);

  List<String> getHistory() => _storage.getHistory();
  Future<void> saveHistory(List<String> l) => _storage.saveHistory(l);

  CityLocation? getLastCity() => _storage.getLastCity();
  Future<void> saveLastCity(CityLocation c) => _storage.saveLastCity(c);
}
