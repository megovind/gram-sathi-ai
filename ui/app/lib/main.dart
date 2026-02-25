import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = await StorageService.init();

  // Restore JWT into ApiService if user already logged in
  final api = ApiService(token: storage.token);

  runApp(GramSathiApp(storage: storage, api: api));
}

class GramSathiApp extends StatelessWidget {
  final StorageService storage;
  final ApiService api;

  const GramSathiApp({super.key, required this.storage, required this.api});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ApiService>.value(value: api),
        Provider<AudioService>(create: (_) => AudioService()),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(storage);
          return MaterialApp.router(
            title: 'GramSathi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
