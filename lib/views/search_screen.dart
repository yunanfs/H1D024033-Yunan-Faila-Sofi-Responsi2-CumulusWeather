import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/city_location.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/city_tile.dart';
import 'widgets/state_views.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    FocusScope.of(context).unfocus();
    if (value != null) _controller.text = value;
    context.read<SearchViewModel>().search(_controller.text);
  }

  void _select(CityLocation city) {
    FocusScope.of(context).unfocus();
    context.read<WeatherViewModel>().selectCity(city);
    context.read<NavigationViewModel>().goTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<SearchViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cari Lokasi Kota', style: t.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Temukan prakiraan cuaca kota di seluruh dunia',
            style: t.textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: Purwokerto',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          vm.clear();
                          setState(() {});
                        }),
                filled: true,
                fillColor: t.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: t.colorScheme.outlineVariant)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: t.colorScheme.outlineVariant)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
                minimumSize: const Size(64, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            onPressed: _submit,
            child: const Text('Cari'),
          ),
        ]),
        const SizedBox(height: 16),
        Expanded(child: _body(context, vm)),
      ]),
    );
  }

  Widget _body(BuildContext context, SearchViewModel vm) {
    switch (vm.status) {
      case SearchStatus.loading:
        return const LoadingView(message: 'Mencari kota...');
      case SearchStatus.error:
        return MessageView(
          icon: Icons.wifi_off_rounded,
          title: 'Pencarian gagal',
          subtitle: vm.errorMessage,
          actionLabel: 'Coba Lagi',
          onAction: () => vm.search(_controller.text),
        );
      case SearchStatus.empty:
        return MessageView(
          icon: Icons.search_off_rounded,
          title: 'Kota tidak ditemukan',
          subtitle: 'Tidak ada hasil untuk "${vm.lastQuery}". Coba kata kunci lain.',
        );
      case SearchStatus.success:
        final fav = context.watch<FavoritesViewModel>();
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: vm.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final city = vm.results[i];
            final isFav = fav.isFavorite(city);
            return CityTile(
              city: city,
              onTap: () => _select(city),
              trailing: IconButton(
                tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
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
                    color: isFav
                        ? const Color(0xFFE11D48)
                        : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          },
        );
      case SearchStatus.idle:
        return _History(onPick: _submit);
    }
  }
}

class _History extends StatelessWidget {
  const _History({required this.onPick});
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final t = Theme.of(context);
    if (vm.history.isEmpty) {
      return const MessageView(
        icon: Icons.travel_explore_rounded,
        title: 'Mulai mencari',
        subtitle: 'Ketik nama kota lalu tekan Cari untuk melihat cuacanya.',
      );
    }
    return ListView(children: [
      Row(children: [
        Expanded(child: Text('Riwayat Pencarian', style: t.textTheme.titleMedium)),
        TextButton(onPressed: vm.clearHistory, child: const Text('Hapus semua')),
      ]),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final h in vm.history)
          InputChip(
            avatar: const Icon(Icons.history_rounded, size: 18),
            label: Text(h),
            onPressed: () => onPick(h),
            onDeleted: () => vm.removeHistory(h),
          ),
      ]),
    ]);
  }
}
