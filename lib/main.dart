
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/weather_api_service.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID');

  // Inisialisasi SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Inisialisasi repository
  final repo = WeatherRepository(
    WeatherApiService(),
    LocalStorageService(prefs),
  );

  runApp(CumulusWeatherApp(repository: repo));
}

class CumulusWeatherApp extends StatelessWidget {
  const CumulusWeatherApp({
    super.key,
    required this.repository,
  });

  final WeatherRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NavigationViewModel(),
        ),

        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(repository)..init(),
        ),

        ChangeNotifierProvider(
          create: (_) => SearchViewModel(repository),
        ),

        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Cumulus Weather',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
