import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/app_state/realtime_listener.dart';
import 'package:stibu/main.dart';

enum RealtimeUpdateType { create, update, delete }

extension RealtimeUpdateTypeExtension on RealtimeUpdateType {
  static const _values = {
    RealtimeUpdateType.create: "create",
    RealtimeUpdateType.update: "update",
    RealtimeUpdateType.delete: "delete",
  };

  static RealtimeUpdateType fromString(String value) {
    return _values.entries.firstWhere((entry) => entry.value == value).key;
  }
}

class RealtimeUpdate<T> {
  final RealtimeUpdateType type;
  final T item;

  RealtimeUpdate(this.type, this.item);
}

RealtimeUpdate<T> _realtimeUpdateFromMessage<T>(
  RealtimeMessage message,
  T Function(Document doc) fromAppwrite,
) {
  final event = message.events.first.split(".").last;
  final eventType = RealtimeUpdateTypeExtension.fromString(event);

  return RealtimeUpdate(
    eventType,
    fromAppwrite(Document.fromMap(message.payload)),
  );
}

class AppState {
  final _isAuthenticated = BehaviorSubject<bool>.seeded(false);
  late final ValueStream<bool> isAuthenticated = _isAuthenticated.stream;

  // Collection Realtime events

  late final RealtimeListener _realtimeListener;

  final _customerUpdates =
      StreamController<RealtimeUpdate<Customers>>.broadcast();
  Stream<RealtimeUpdate<Customers>> get customerUpdates =>
      _customerUpdates.stream;

  final _invoicesUpdates =
      StreamController<RealtimeUpdate<Invoices>>.broadcast();
  Stream<RealtimeUpdate<Invoices>> get invoicesUpdates =>
      _invoicesUpdates.stream;

  final _ordersUpdates = StreamController<RealtimeUpdate<Orders>>.broadcast();
  Stream<RealtimeUpdate<Orders>> get ordersUpdates => _ordersUpdates.stream;

  final _expensesUpdates =
      StreamController<RealtimeUpdate<Expenses>>.broadcast();
  Stream<RealtimeUpdate<Expenses>> get expensesUpdates =>
      _expensesUpdates.stream;

  final _calendarEventsUpdates =
      StreamController<RealtimeUpdate<CalendarEvents>>.broadcast();
  Stream<RealtimeUpdate<CalendarEvents>> get calendarEventsUpdates =>
      _calendarEventsUpdates.stream;

  late final Map<String, void Function(RealtimeMessage message)>
      _realtimeListeners = {
    "databases.${Customers.databaseId}.collections.${Customers.collectionInfo.$id}.documents":
        (message) => _customerUpdates.add(_realtimeUpdateFromMessage<Customers>(
            message, Customers.fromAppwrite)),
    "databases.${Invoices.databaseId}.collections.${Invoices.collectionInfo.$id}.documents":
        (message) => _invoicesUpdates.add(_realtimeUpdateFromMessage<Invoices>(
            message, Invoices.fromAppwrite)),
    "databases.${Orders.databaseId}.collections.${Orders.collectionInfo.$id}.documents":
        (message) async {
      // Inject products into the order as they are not included in the realtime message
      final event = message.events.first.split(".").last;
      final eventType = RealtimeUpdateTypeExtension.fromString(event);

      if (eventType == RealtimeUpdateType.delete) {
        final order = Orders.fromAppwrite(Document.fromMap(message.payload));
        _ordersUpdates.add(RealtimeUpdate(eventType, order));
        return;
      }

      final orderId = Document.fromMap(message.payload).$id;
      final order = await Orders.get(orderId);
      if (order.isFailure) {
        log.warning("Failed to fetch order $orderId: ${order.failure}");
        return;
      }
      _ordersUpdates.add(RealtimeUpdate(eventType, order.success));
    },
    "databases.${Expenses.databaseId}.collections.${Expenses.collectionInfo.$id}.documents":
        (message) => _expensesUpdates.add(_realtimeUpdateFromMessage<Expenses>(
            message, Expenses.fromAppwrite)),
    "databases.${CalendarEvents.databaseId}.collections.${CalendarEvents.collectionInfo.$id}.documents":
        (message) => _calendarEventsUpdates.add(
            _realtimeUpdateFromMessage<CalendarEvents>(
                message, CalendarEvents.fromAppwrite)),
  };

  AppState() {
    final appwrite = getIt<AppwriteClient>();
    _realtimeListener = RealtimeListener(appwrite.realtime);

    appwrite.account.get().then((account) {
      log.info("Got account: ${account.name}");
      _isAuthenticated.add(true);
    }).catchError((e) {
      log.warning("Failed to get account: $e");
    });

    isAuthenticated.listen((isAuthenticated) async {
      if (isAuthenticated) {
        _realtimeListener.addSubscriptions(_realtimeListeners);
      } else {
        _realtimeListener.removeSubscriptions(_realtimeListeners.keys.toList());
      }
    });
  }

  Future<Result<void, String>> login(String email, String password) async {
    final appwrite = getIt<AppwriteClient>();
    try {
      await appwrite.account
          .createEmailPasswordSession(email: email, password: password);
      _isAuthenticated.add(true);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to login");
    }
  }

  Future<Result<void, String>> logout() async {
    final appwrite = getIt<AppwriteClient>();
    try {
      await appwrite.account.deleteSession(sessionId: "current");
      _isAuthenticated.add(false);
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to logout");
    }
  }

  Future<Result<void, String>> createAccount(
      String email, String password, String name) async {
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
      return Failure(e.message ?? "Failed to create Account");
    }
  }
}
