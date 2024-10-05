import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/main.dart';

class Authentication {
  final _isAuthenticated = BehaviorSubject<bool>.seeded(false);
  late final ValueStream<bool> isAuthenticated = _isAuthenticated.stream;

  Authentication() {
    final appwrite = getIt<AppwriteClient>();

    unawaited(
      appwrite.account.get().then((account) {
        log.info('Got account: ${account.name}');
      _isAuthenticated.add(true);
    }).catchError((e) {
        log.warning('Failed to get account: $e');
      }),
    );
  }

  Future<Result<void, String>> login(String email, String password) async {
    final appwrite = getIt<AppwriteClient>();
    try {
      await appwrite.account
          .createEmailPasswordSession(email: email, password: password);
      _isAuthenticated.add(true);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Failed to login');
    }
  }

  Future<Result<void, String>> logout() async {
    final appwrite = getIt<AppwriteClient>();
    try {
      await appwrite.account.deleteSession(sessionId: 'current');
      _isAuthenticated.add(false);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Failed to logout');
    }
  }

  Future<Result<void, String>> createAccount(
    String email,
    String password,
    String name,
  ) async {
    final appwrite = getIt<AppwriteClient>();
    try {
      await appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Failed to create Account');
    }
  }
}
