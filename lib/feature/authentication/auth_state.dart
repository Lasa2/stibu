import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:june/june.dart';
import 'package:stibu/main.dart';
import 'package:stibu/router.gr.dart';

final client = Client()
    .setEndpoint('https://appwrite.vee.icu/v1')
    .setProject('66ba8a48000da48dd442');

final account = Account(client);

class Auth extends JuneService {
  bool isAuthenticated = false;
  Session? session;

  final authStreamController = StreamController<bool>.broadcast();
  Stream<bool> get authStream => authStreamController.stream;

  @override
  void onInit() {
    super.onInit();

    account.getSession(sessionId: "current").then((value) {
      session = value;
      isAuthenticated = true;
      authStreamController.add(isAuthenticated);
      appRouter.root.replaceAll([const DashboardRoute()]);
    }, onError: (e) {
      log.severe('Failed to get current session: $e');
    });
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      session = response;
      isAuthenticated = true;
      authStreamController.add(isAuthenticated);
      log.info('Logged in: $response');
    } on AppwriteException catch (e) {
      log.severe('Failed to login: ${e.message}', e.message);
    }
  }

  Future<void> logout() async {
    account.deleteSession(
      sessionId: session!.$id,
    );

    isAuthenticated = false;
    session = null;
    authStreamController.add(isAuthenticated);
  }
}
