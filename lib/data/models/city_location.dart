/// Model lokasi kota (hasil Geocoding API & disimpan di local storage).
class CityLocation {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CityLocation.fromGeocoding(Map<String, dynamic> j) => CityLocation(
        name: (j['name'] ?? '-').toString(),
        admin1: j['admin1']?.toString(),
        country: (j['country'] ?? '').toString(),
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );

  factory CityLocation.fromJson(Map<String, dynamic> j) =>
      CityLocation.fromGeocoding(j);

  Map<String, dynamic> toJson() => {
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty && admin1 != name) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  String get coordinates =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';

  String get key =>
      '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) => other is CityLocation && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
