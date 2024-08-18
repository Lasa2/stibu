import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu/backend.dart';
import 'package:stibu/feature/router/router.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

abstract class AuthState {
  Session? get session;

  Stream<bool> get authStream;
  bool get isAuthenticated;
  Future<User> get user;
  Future<Preferences> get preferences;

  Future<Result<void, String?>> login(String email, String password);
  Future<void> logout();
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  );
}

class AuthStateAppwrite implements AuthState {
  final _backend = getIt<Backend>();
  late final _account = _backend.account;
  Session? _session;
  final streamController = StreamController<bool>.broadcast();

  @override
  Session? get session => _session;
  @override
  Stream<bool> get authStream => streamController.stream;
  @override
  bool get isAuthenticated => _session != null;
  @override
  Future<User> get user async {
    if (_session == null) {
      throw Exception('Session is null');
    }

    return _account.get();
  }

  @override
  Future<Preferences> get preferences async {
    if (_session == null) {
      throw Exception('Session is null');
    }

    return _account.getPrefs();
  }

  Future<AuthStateAppwrite> init() async {
    try {
      _session = await _account.getSession(sessionId: "current");

      if (_session != null) {
        streamController.add(true);
        getIt<AppRouter>().root.replaceAll([const DashboardRoute()]);
      }
    } on AppwriteException catch (e) {
      log.warning('Failed to get session: $e');
    }

    return this;
  }

  @override
  Future<Result<void, String?>> login(String email, String password) async {
    try {
      final response = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _session = response;
      streamController.add(true);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }

  @override
  Future<void> logout() async {
    await _account.deleteSession(sessionId: "current").catchError((e) {
      log.warning('Failed to logout: $e');
    });

    _session = null;
    streamController.add(false);
  }

  @override
  Future<Result<User, String?>> createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await _account.create(
        userId: ID.unique(),
        name: name,
        email: email,
        password: password,
      );
      return Success(result);
    } on AppwriteException catch (e) {
      return Failure(e.message);
    }
  }
}
