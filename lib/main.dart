import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:stibu/api/avatars.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/app_state/app_state.dart';
import 'package:stibu/feature/router/router.dart';
import 'package:stibu/l10n/generated/l10n.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_protocol/url_protocol.dart';

final log = Logger('Stibu');
final getIt = GetIt.instance;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceLocale = PlatformDispatcher.instance.locale;
  Intl.defaultLocale = deviceLocale.toLanguageTag();
  initializeDateFormatting(deviceLocale.toLanguageTag());

  await initializeDateFormatting();

  SystemTheme.fallbackColor = const Color(0xFF865432);
  await SystemTheme.accentColor.load();

  GetIt.I.registerSingleton<AppRouter>(AppRouter());
  final client = GetIt.I.registerSingleton<AppwriteClient>(AppwriteClient(
    Client()
        .setEndpoint('https://appwrite.vee.icu/v1')
        .setProject('66ba8a48000da48dd442')
        .setEndPointRealtime('wss://appwrite.vee.icu/v1/realtime'),
  ));

  GetIt.I.registerLazySingleton<AppState>(() => AppState());
  GetIt.I.registerLazySingleton<AvatarsRepository>(
      () => AvatarsRepository(client.avatars));

  registerProtocolHandler("stibu");

  Logger.root.level = Level.ALL; // defaults to Level.INFO

  if (kDebugMode) {
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  runApp(const StibuApp());
}

class StibuApp extends StatelessWidget {
  const StibuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AppState>();
    final router = getIt<AppRouter>();

    return FluentApp.router(
      title: 'Stibu',
      routerConfig: router.config(
        reevaluateListenable: ReevaluateListenable.stream(auth.isAuthenticated),
        navigatorObservers: () => [RouteLogger()],
      ),
      localizationsDelegates: Lang.localizationsDelegates,
      supportedLocales: Lang.supportedLocales,
    );
  }
}
