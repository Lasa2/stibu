import 'package:appwrite/appwrite.dart';

class AppwriteBackend {
  final Client client;
  late final Account account = Account(client);
  late final Databases databases = Databases(client);
  late final Realtime realtime = Realtime(client);
  late final Functions functions = Functions(client);

  AppwriteBackend._(this.client);

  factory AppwriteBackend(
    String endpoint,
    String project,
    String? realtimeEndpoint, {
    bool selfSigned = false,
  }) {
    final client = Client()
        .setEndpoint(endpoint)
        .setProject(project)
        .setSelfSigned(status: selfSigned);
    if (realtimeEndpoint != null) {
      client.setEndPointRealtime(realtimeEndpoint);
    }

    return AppwriteBackend._(client);
  }
}
