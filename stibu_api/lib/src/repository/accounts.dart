import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';

abstract class AccountsRepository {
  ValueStream<Session?> get isAuthenticated;
  Future<Result<User, String>> get user;
  Future<Result<Preferences, String>> get preferences;
  Future<Result<Session, String>> get session;

  Future<Result<Session, String?>> login(String email, String password);
  Future<Result<void, String>> logout();
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  );
}

class AccountsRepositoryAppwrite implements AccountsRepository {
  final Account _account;
  final _isAuthenticated = BehaviorSubject<Session?>.seeded(null);

  @override
  late ValueStream<Session?> isAuthenticated = _isAuthenticated.stream;

  @override
  Future<Result<User, String>> get user async {
    try {
      return Success(await _account.get());
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get user");
    }
  }

  @override
  Future<Result<Preferences, String>> get preferences async {
    try {
      return Success(await _account.getPrefs());
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get preferences");
    }
  }

  AccountsRepositoryAppwrite(this._account) {
    session.then((result) {
      if (result.isSuccess) {
        _isAuthenticated.add(result.success);
      }
    });
  }

  @override
  Future<Result<Session, String>> get session async {
    try {
      return Success(await _account.getSession(sessionId: "current"));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get session");
    }
  }

  @override
  Future<Result<Session, String?>> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
          email: email, password: password);
      _isAuthenticated.add(session);
      return Success(session);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }

  @override
  Future<Result<void, String>> logout() async {
    try {
      await _account.deleteSession(sessionId: "current");
      _isAuthenticated.add(null);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to logout");
    }
  }

  @override
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      final session = await _account.getSession(sessionId: "current");
      _isAuthenticated.add(session);
      return Success(user);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }
}
