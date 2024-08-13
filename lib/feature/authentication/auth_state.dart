import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:june/june.dart';
import 'package:result_type/result_type.dart';
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

  Future<Result<void, String?>> login(String email, String password) async {
    try {
      final response = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      session = response;
      isAuthenticated = true;
      authStreamController.add(isAuthenticated);
      log.info('Logged in: $response');
      return Success(null);
    } on AppwriteException catch (e) {
      log.severe('Failed to login: ${e.message}', e.message);
      return Failure(e.message);
    }
  }

  Future<void> logout() async {
    if (session == null) {
      log.severe('Session is null when logging out');
    } else {
      account.deleteSession(
        sessionId: session!.$id,
      );
    }

    isAuthenticated = false;
    session = null;
    authStreamController.add(isAuthenticated);
  }

  Future<Result<void, String?>> createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await account.create(
        userId: ID.unique(),
        name: name,
        email: email,
        password: password,
      );
      log.info('Account created: $result');
      return Success(null);
    } on AppwriteException catch (e) {
      log.severe(e.message);
      return Failure(e.message);
    }
  }
}
