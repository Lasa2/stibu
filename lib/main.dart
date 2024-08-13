import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:june/june.dart';
import 'package:logging/logging.dart';
import 'package:stibu/feature/authentication/auth_state.dart';
import 'package:stibu/l10n/generated/l10n.dart';
import 'package:stibu/router.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_protocol/url_protocol.dart';

final log = Logger('Stibu');
final client = Client()
    .setEndpoint('https://appwrite.vee.icu/v1')
    .setProject('66ba8a48000da48dd442');

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.fallbackColor = const Color(0xFF865432);
  await SystemTheme.accentColor.load();

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

final appRouter = AppRouter();

class StibuApp extends StatefulWidget {

  const StibuApp({super.key});

  @override
  State<StibuApp> createState() => _StibuAppState();
}

class _StibuAppState extends State<StibuApp> {
  final auth = June.getState(() => Auth(), permanent: true);

  @override
  void initState() {
    super.initState();
    auth.authStream
        .listen((isAuthenticated) => log.info('Auth state: $isAuthenticated'));
  }

  @override
  Widget build(BuildContext context) {

    return FluentApp.router(
        title: 'Stibu',
        routerConfig: appRouter.config(
          reevaluateListenable: ReevaluateListenable.stream(auth.authStream),
          navigatorObservers: () => [RouteLogger()],
        ),
        localizationsDelegates: Lang.localizationsDelegates,
        supportedLocales: Lang.supportedLocales);
  }
}
