import 'package:args/args.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multi_instance/multi_instance.dart';
import 'package:stibu/l10n/generated/l10n.dart';
import 'package:stibu/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_protocol/url_protocol.dart';

final log = Logger('Stibu');

Future<void> main(List<String> args) async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  if (kDebugMode) {
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  registerProtocolHandler("test-protocol", arguments: ["--url", "%s"]);


  var parser = ArgParser();
  parser.addOption('url');

  var results = parser.parse(args);
  log.info('URL: ${results.option('url')}');

  if (await isFirstInstance(args)) {
    log.info('First instance');
    onSecondInstance((List<String> args) {
      log.info('Second instance args: $args');
    });
  } else {
    log.info('Second instance');
  }

  await Supabase.initialize(
    url: 'https://supabase.vee.icu',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzMzI3MjAwLAogICJleHAiOiAxODgxMDkzNjAwCn0.-C14qzvWh73503HrP_L-_WJT9aAkrGvRzFTc-BUJu6I',
  );

  runApp(StibuApp());
}

class StibuApp extends StatelessWidget {
  StibuApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
        title: 'Stibu',
        routerConfig: _appRouter.config(),
        localizationsDelegates: Lang.localizationsDelegates,
        supportedLocales: Lang.supportedLocales
    );
  }
}
