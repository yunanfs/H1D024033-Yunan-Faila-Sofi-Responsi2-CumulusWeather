import 'package:flutter/foundation.dart';

import '../data/models/city_location.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/weather_api_service.dart';

enum SearchStatus { idle, loading, success, empty, error }

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repo) {
    _history = _repo.getHistory();
  }
  final WeatherRepository _repo;

  SearchStatus _status = SearchStatus.idle;
  List<CityLocation> _results = [];
  List<String> _history = [];
  String _error = '';
  String _lastQuery = '';
  int _requestId = 0;

  SearchStatus get status => _status;
  List<CityLocation> get results => _results;
  List<String> get history => _history;
  String get errorMessage => _error;
  String get lastQuery => _lastQuery;

  Future<void> search(String raw) async {
    final q = raw.trim();
    if (q.isEmpty) {
      clear();
      return;
    }
    if (q.length < 2) {
      _error = 'Masukkan minimal 2 karakter nama kota.';
      _status = SearchStatus.error;
      notifyListeners();
      return;
    }

    final id = ++_requestId;
    _lastQuery = q;
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      final list = await _repo.searchCities(q); // request nyata ke API
      if (id != _requestId) return;
      _results = list;
      _status = list.isEmpty ? SearchStatus.empty : SearchStatus.success;
      if (list.isNotEmpty) await _addHistory(q);
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _error = e.message;
      _status = SearchStatus.error;
    } catch (_) {
      if (id != _requestId) return;
      _error = 'Terjadi kesalahan tak terduga.';
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  void clear() {
    _requestId++;
    _status = SearchStatus.idle;
    _results = [];
    notifyListeners();
  }

  Future<void> _addHistory(String q) async {
    _history = [
      q,
      ..._history.where((e) => e.toLowerCase() != q.toLowerCase()),
    ].take(8).toList();
    await _repo.saveHistory(_history);
  }

  Future<void> removeHistory(String q) async {
    _history = _history.where((e) => e != q).toList();
    await _repo.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    await _repo.saveHistory(_history);
    notifyListeners();
  }
}
