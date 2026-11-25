import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/city_tile.dart';
import 'widgets/state_views.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final fav = context.watch<FavoritesViewModel>();
    final current = context.watch<WeatherViewModel>().city;
    final nav = context.read<NavigationViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kota Favorit', style: t.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Akses cepat lokasi pilihan Anda', style: t.textTheme.bodySmall),
            ]),
          ),
          IconButton.filledTonal(
              tooltip: 'Tambah kota',
              onPressed: () => nav.goTo(1),
              icon: const Icon(Icons.add_rounded)),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: fav.items.isEmpty
              ? MessageView(
                  icon: Icons.favorite_border_rounded,
                  title: 'Belum ada favorit',
                  subtitle:
                      'Cari kota lalu tekan ikon hati untuk menyimpannya di sini.',
                  actionLabel: 'Cari Kota',
                  onAction: () => nav.goTo(1),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: fav.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final city = fav.items[i];
                    return Dismissible(
                      key: ValueKey(city.key),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                            color: t.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(Icons.delete_rounded,
                            color: t.colorScheme.onErrorContainer),
                      ),
                      onDismissed: (_) => fav.remove(city),
                      child: CityTile(
                        city: city,
                        highlight: city == current,
                        onTap: () {
                          context.read<WeatherViewModel>().selectCity(city);
                          nav.goTo(0);
                        },
                        trailing: IconButton(
                          tooltip: 'Hapus',
                          onPressed: () => fav.remove(city),
                          icon: Icon(Icons.delete_outline_rounded,
                              color: t.colorScheme.error),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
