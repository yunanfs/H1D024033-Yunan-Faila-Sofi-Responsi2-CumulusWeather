import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/utils/weather_code.dart';
import '../data/models/city_location.dart';
import '../data/models/weather_data.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/soft_card.dart';
import 'widgets/state_views.dart';

String _temp(double v) => '${v.round()}°C';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    return Column(children: [
      _TopBar(
        onSearch: () => context.read<NavigationViewModel>().goTo(1),
        onRefresh: vm.refresh,
      ),
      Expanded(child: _body(context, vm)),
    ]);
  }

  Widget _body(BuildContext context, WeatherViewModel vm) {
    switch (vm.status) {
      case ViewStatus.loading:
        return LoadingView(message: 'Memuat cuaca ${vm.city.name}...');
      case ViewStatus.error:
        return MessageView(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal memuat cuaca',
          subtitle: vm.errorMessage,
          actionLabel: 'Coba Lagi',
          onAction: vm.retry,
        );
      case ViewStatus.empty:
        return MessageView(
          icon: Icons.inbox_rounded,
          title: 'Data cuaca kosong',
          subtitle: 'Server tidak mengirim data untuk lokasi ini.',
          actionLabel: 'Muat Ulang',
          onAction: vm.retry,
        );
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              _HeroCard(city: vm.city, data: vm.weather!),
              if (vm.weather!.hourly.isNotEmpty) ...[
                const _SectionTitle('Per Jam (24 Jam ke Depan)'),
                _HourlyStrip(items: vm.weather!.hourly),
              ],
              const _SectionTitle('Detail Cuaca Saat Ini'),
              _DetailGrid(data: vm.weather!),
              const _SectionTitle('Prakiraan 7 Hari ke Depan'),
              _DailyList(items: vm.weather!.daily),
              const SizedBox(height: 16),
              Center(
                child: Text('Data: Open-Meteo.com',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSearch, required this.onRefresh});
  final VoidCallback onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.cloud_rounded, color: t.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cumulus Weather', style: t.textTheme.titleLarge),
            Text('Informasi & Prakiraan Cuaca', style: t.textTheme.bodySmall),
          ]),
        ),
        IconButton(
            tooltip: 'Cari kota',
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded)),
        IconButton(
            tooltip: 'Muat ulang',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded)),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.city, required this.data});
  final CityLocation city;
  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final info = WeatherCode.describe(c.weatherCode);
    final colors = WeatherCode.gradient(info.category, c.isDay);
    final today = data.today;
    final fav = context.watch<FavoritesViewModel>();
    final isFav = fav.isFavorite(city);
    const white = Colors.white;
    final dateText =
        DateFormat('EEEE, d MMMM y • HH:mm', 'id_ID').format(c.time);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
            colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: colors.last.withAlpha(90),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.location_on_rounded, color: white, size: 22),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(city.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: white)),
              Text(city.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          IconButton.filledTonal(
            tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
            style: IconButton.styleFrom(
                backgroundColor: Colors.white24, foregroundColor: white),
            onPressed: () async {
              final added = await fav.toggle(city);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(added
                        ? '${city.name} ditambahkan ke favorit'
                        : '${city.name} dihapus dari favorit')));
            },
            icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFFF6B81) : white),
          ),
        ]),
        const SizedBox(height: 8),
        Text(dateText,
            style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_temp(c.temperature),
                  style: const TextStyle(
                      color: white,
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1.05)),
              const SizedBox(height: 4),
              Text(info.label,
                  style: const TextStyle(
                      color: white, fontSize: 20, fontWeight: FontWeight.w700)),
              Text('Terasa seperti ${_temp(c.apparentTemperature)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          Container(
            width: 96,
            height: 96,
            decoration:
                const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Icon(info.icon(c.isDay), color: white, size: 52),
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            _MiniStat('Suhu Min', today == null ? '-' : _temp(today.tempMin)),
            _divider(),
            _MiniStat('Suhu Maks', today == null ? '-' : _temp(today.tempMax)),
            _divider(),
            _MiniStat('Peluang Hujan',
                today == null ? '-' : '${today.rainProbability}%'),
          ]),
        ),
      ]),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 28, color: Colors.white.withAlpha(70));
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      );
}

class _HourlyStrip extends StatelessWidget {
  const _HourlyStrip({required this.items});
  final List<HourlyForecast> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final h = items[i];
          final info = WeatherCode.describe(h.weatherCode);
          return SizedBox(
            width: 68,
            child: SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              highlight: i == 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(i == 0 ? 'Kini' : DateFormat('HH:mm').format(h.time),
                      style: t.textTheme.labelMedium),
                  Icon(info.icon(h.isDay), color: t.colorScheme.primary),
                  Text(_temp(h.temperature),
                      style: t.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${h.rainProbability}%',
                      style: t.textTheme.labelSmall
                          ?.copyWith(color: t.colorScheme.primary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.data});
  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final d = data.today;
    final tf = DateFormat('HH:mm');
    final items = <(IconData, String, String)>[
      (Icons.water_drop_rounded, 'Kelembapan', '${c.humidity}%'),
      (Icons.air_rounded, 'Kecepatan Angin', '${c.windSpeed.toStringAsFixed(1)} km/j'),
      (Icons.grain_rounded, 'Curah Hujan', '${c.precipitation.toStringAsFixed(1)} mm'),
      (Icons.umbrella_rounded, 'Peluang Hujan',
          d == null ? '-' : '${d.rainProbability}%'),
      (Icons.thermostat_rounded, 'Suhu Min / Maks',
          d == null ? '-' : '${d.tempMin.round()}° / ${d.tempMax.round()}°'),
      (Icons.device_thermostat_rounded, 'Suhu Terasa', _temp(c.apparentTemperature)),
      (Icons.wb_twilight_rounded, 'Matahari Terbit',
          d?.sunrise == null ? '-' : tf.format(d!.sunrise!)),
      (Icons.nights_stay_rounded, 'Matahari Terbenam',
          d?.sunset == null ? '-' : tf.format(d!.sunset!)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.85,
      children: [for (final i in items) _StatTile(icon: i.$1, label: i.$2, value: i.$3)],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SoftCard(
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: t.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.labelSmall
                        ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: t.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ]),
        ),
      ]),
    );
  }
}

class _DailyList extends StatelessWidget {
  const _DailyList({required this.items});
  final List<DailyForecast> items;

  String _label(int i, DateTime d) {
    if (i == 0) return 'Hari Ini';
    if (i == 1) return 'Besok';
    return DateFormat('EEEE', 'id_ID').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                flex: 4,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_label(i, items[i].date),
                      style: t.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(DateFormat('d MMM', 'id_ID').format(items[i].date),
                      style: t.textTheme.bodySmall),
                ]),
              ),
              Icon(WeatherCode.describe(items[i].weatherCode).icon(true),
                  color: t.colorScheme.primary),
              Expanded(
                flex: 2,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.water_drop_outlined,
                      size: 14, color: t.colorScheme.primary),
                  const SizedBox(width: 2),
                  Text('${items[i].rainProbability}%',
                      style: t.textTheme.labelMedium
                          ?.copyWith(color: t.colorScheme.primary)),
                ]),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${items[i].tempMin.round()}° / ${items[i].tempMax.round()}°',
                  textAlign: TextAlign.end,
                  style: t.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
          if (i != items.length - 1)
            Divider(height: 1, color: t.colorScheme.outlineVariant.withAlpha(120)),
        ],
      ]),
    );
  }
}
