import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';

abstract class AccountsRepository {
  ValueStream<Session?> get sessionStream;
  ValueStream<User?> get userStream;
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
  final _sessionStream = BehaviorSubject<Session?>.seeded(null);

  @override
  late ValueStream<Session?> sessionStream = _sessionStream.stream;

  final _userStream = BehaviorSubject<User?>.seeded(null);
  @override
  late ValueStream<User?> userStream = _userStream.stream;

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
        _sessionStream.add(result.success);
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
      _sessionStream.add(session);

      final user = await _account.get();
      _userStream.add(user);
      return Success(session);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }

  @override
  Future<Result<void, String>> logout() async {
    try {
      await _account.deleteSession(sessionId: "current");
      _sessionStream.add(null);
      _userStream.add(null);
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
      _sessionStream.add(session);
      _userStream.add(user);
      return Success(user);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }
}
