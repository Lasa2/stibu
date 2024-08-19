import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:stibu/feature/router/router.dart';
import 'package:stibu/l10n/generated/l10n.dart';
import 'package:stibu_api/stibu_api.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_protocol/url_protocol.dart';

final log = Logger('Stibu');
final client = Client()
    .setEndpoint('https://appwrite.vee.icu/v1')
    .setProject('66ba8a48000da48dd442')
    .setEndPointRealtime('wss://realtime.vee.icu');

final getIt = GetIt.instance;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemTheme.fallbackColor = const Color(0xFF865432);
  await SystemTheme.accentColor.load();

  GetIt.I.registerSingleton<AppRouter>(AppRouter());
  final backend = GetIt.I.registerSingleton<AppwriteBackend>(AppwriteBackend(
    'https://appwrite.vee.icu/v1',
    '66ba8a48000da48dd442',
    'wss://appwrite.vee.icu/v1/realtime',
  ));
  final account = GetIt.I.registerSingleton<AccountsRepository>(
      AccountsRepositoryAppwrite(backend.account));
  GetIt.I.registerSingleton<CustomerRepository>(CustomerRepositoryAppwrite(
    backend.databases,
    backend.realtime,
    account as AccountsRepositoryAppwrite,
  ));

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
    final auth = getIt<AccountsRepository>();
    final router = getIt<AppRouter>();

    return FluentApp.router(
        title: 'Stibu',
        routerConfig: router.config(
          reevaluateListenable:
              ReevaluateListenable.stream(auth.isAuthenticated),
          navigatorObservers: () => [RouteLogger()],
        ),
        localizationsDelegates: Lang.localizationsDelegates,
        supportedLocales: Lang.supportedLocales);
  }
}
