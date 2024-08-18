import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';

abstract class AccountsRepository {
  Session? get session;
  Stream<bool> get isAuthenticatedStream;
  bool get isAuthenticated;
  Future<User> get user;
  Future<Preferences> get preferences;

  Future<Result<Session, String?>> login(String email, String password);
  Future<void> logout();
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  );
}

class AccountsRepositoryAppwrite implements AccountsRepository {
  final Account _account;
  final StreamController<bool> _isAuthenticatedController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get isAuthenticatedStream => _isAuthenticatedController.stream;

  @override
  bool get isAuthenticated => session != null;

  @override
  Future<User> get user async {
    if (session == null) {
      throw Exception('Session is null');
    }

    return _account.get();
  }

  @override
  Future<Preferences> get preferences async {
    if (session == null) {
      throw Exception('Session is null');
    }

    return _account.getPrefs();
  }

  @override
  Session? session;

  AccountsRepositoryAppwrite(this._account) {
    _account.getSession(sessionId: "current").then((value) {
      _isAuthenticatedController.add(true);
      return session = value;
    });
  }

  @override
  Future<Result<Session, String?>> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
          email: email, password: password);
      _isAuthenticatedController.add(true);
      return Success(session);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }

  @override
  Future<void> logout() async {
    await _account.deleteSession(sessionId: "current");
    _isAuthenticatedController.add(false);
  }

  @override
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final session = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      _isAuthenticatedController.add(true);
      return Success(session);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }
}
