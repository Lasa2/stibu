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
    'wss://realtime.vee.icu',
  ));
  final account = GetIt.I.registerSingleton<AccountsRepository>(
      AccountsRepositoryAppwrite(backend.account));
  GetIt.I.registerSingleton<CustomerRepository>(CustomerRepositoryAppwrite(
      backend.databases,
      backend.realtime,
      account as AccountsRepositoryAppwrite));

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

class StibuApp extends StatefulWidget {
  const StibuApp({super.key});

  @override
  State<StibuApp> createState() => _StibuAppState();
}

class _StibuAppState extends State<StibuApp> {
  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();
    final authFuture = getIt.getAsync<AccountsRepository>();

    return FutureBuilder(
        future: authFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final auth = snapshot.data as AccountsRepository;

            return FluentApp.router(
                title: 'Stibu',
                routerConfig: router.config(
                  reevaluateListenable:
                      ReevaluateListenable.stream(auth.isAuthenticatedStream),
                  navigatorObservers: () => [RouteLogger()],
                ),
                localizationsDelegates: Lang.localizationsDelegates,
                supportedLocales: Lang.supportedLocales);
          } else {
            return const FluentApp(
              title: 'Stibu',
              localizationsDelegates: Lang.localizationsDelegates,
              supportedLocales: Lang.supportedLocales,
              home: NavigationView(
                content: ScaffoldPage(
                  content: Center(
                    child: ProgressRing(),
                  ),
                ),
              ),
            );
          }
        });
  }
}
