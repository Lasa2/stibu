import 'package:appwrite/appwrite.dart';

class Backend {
  final client = Client()
      .setEndpoint('https://appwrite.vee.icu/v1')
      .setProject('66ba8a48000da48dd442')
      .setEndPointRealtime('wss://realtime.vee.icu')
      .setSelfSigned(status: true);

  late final account = Account(client);
  late final database = Databases(client);
  late final realtime = Realtime(client);
}
