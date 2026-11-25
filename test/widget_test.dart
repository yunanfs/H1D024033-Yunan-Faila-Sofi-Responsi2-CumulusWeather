
import 'package:flutter_test/flutter_test.dart';
import 'package:cumulus_weather/data/models/city_location.dart';

void main() {
  group('CityLocation Model Test', () {

    test('CityLocation membaca JSON dengan benar', () {
      final loc = CityLocation.fromJson({
        'name': 'Purwokerto',
        'admin1': 'Jawa Tengah',
        'country': 'Indonesia',
        'latitude': -7.4214,
        'longitude': 109.2342,
      });

      expect(loc.name, 'Purwokerto');
      expect(loc.admin1, 'Jawa Tengah');
      expect(loc.country, 'Indonesia');
      expect(loc.latitude, -7.4214);
      expect(loc.longitude, 109.2342);
    });

    test('CityLocation menghasilkan subtitle dengan benar', () {
      final loc = CityLocation.fromJson({
        'name': 'Purwokerto',
        'admin1': 'Jawa Tengah',
        'country': 'Indonesia',
        'latitude': -7.4214,
        'longitude': 109.2342,
      });

      expect(loc.subtitle, 'Jawa Tengah, Indonesia');
    });

    test('CityLocation menghasilkan koordinat dengan benar', () {
      final loc = CityLocation.fromJson({
        'name': 'Purwokerto',
        'admin1': 'Jawa Tengah',
        'country': 'Indonesia',
        'latitude': -7.4214,
        'longitude': 109.2342,
      });

      expect(loc.coordinates, '-7.42, 109.23');
    });

  });
}
