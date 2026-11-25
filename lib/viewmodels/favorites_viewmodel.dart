import 'package:flutter/foundation.dart';

import '../data/models/city_location.dart';
import '../data/repositories/weather_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel(this._repo) {
    _items = _repo.getFavorites(); // dimuat kembali saat aplikasi dibuka
  }
  final WeatherRepository _repo;

  List<CityLocation> _items = [];
  List<CityLocation> get items => List.unmodifiable(_items);

  bool isFavorite(CityLocation c) => _items.contains(c);

  /// Mengembalikan true jika ditambahkan, false jika dihapus.
  Future<bool> toggle(CityLocation c) async {
    final added = !isFavorite(c);
    if (added) {
      _items = [c, ..._items];
    } else {
      _items = _items.where((e) => e != c).toList();
    }
    notifyListeners();
    await _repo.saveFavorites(_items);
    return added;
  }

  Future<void> remove(CityLocation c) async {
    _items = _items.where((e) => e != c).toList();
    notifyListeners();
    await _repo.saveFavorites(_items);
  }
}
