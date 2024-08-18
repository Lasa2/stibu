import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu/backend.dart';
import 'package:stibu/common/collect_stream.dart';
import 'package:stibu/feature/authentication/repository.dart';
import 'package:stibu/feature/customers/model.dart';
import 'package:stibu/main.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> get customers;

  Future<String> newID();
  Future<List<Customer>> getCustomers();
  Future<Result<Customer, String>> createCustomer(Customer customer);
  Future<Result<Customer, String>> getCustomer(String id);
  Future<Result<void, String>> deleteCustomer(String id);
  Future<Result<Customer, String>> updateCustomer(Customer customer);
}

class CustomerRepositoryAppwrite implements CustomerRepository {
  final _backend = getIt<Backend>();
  late final _database = _backend.database;
  late final _realtime = _backend.realtime;

  final _collector = CollectStream<Customer>();
  RealtimeSubscription? sub;

  @override
  late final customers = _collector.stream;

  CustomerRepositoryAppwrite init() {
    final auth = getIt<AuthState>();

    log.info("Auth state in CustomerRepository: ${auth.isAuthenticated}");
    if (auth.isAuthenticated) {
      initCustomers();
    }

    auth.authStream.listen((authState) async {
      log.info("Auth state listener in CustomerRepository: $authState");
      authState ? await initCustomers() : await disposeCustomers();
    });

    return this;
  }

  Future<void> initCustomers() async {
    final customers = await getCustomers();
    _collector.addItems(customers);

    sub = _realtime.subscribe(
      ["databases.default.collections.customers.documents"],
    );
    sub!.stream.listen((data) {
      log.info("Realtime update: $data");
      final event = data.events.first.split(".").last;
      switch (event) {
        case 'create':
        case 'update':
          final doc = Document.fromMap(data.payload);
          final customer = Customer.fromAppwrite(doc);
          _collector.addItem(customer);
          break;
        case 'delete':
          final doc = Document.fromMap(data.payload);
          final customer = Customer.fromAppwrite(doc);
          _collector.removeItem(customer.id);
          break;
      }
    });
  }

  Future<void> disposeCustomers() async {
    await sub?.close();
    _collector.clear();
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final docs = await _database.listDocuments(
      databaseId: "default",
      collectionId: 'customers',
    );

    return docs.documents.map((doc) => Customer.fromAppwrite(doc)).toList();
  }

  @override
  Future<String> newID() async {
    final doc = await _database.listDocuments(
        databaseId: "default",
        collectionId: 'customers',
        queries: [
          Query.orderDesc("\$id"),
          Query.limit(1),
        ]);
    final lastID = doc.documents.firstOrNull?.$id ?? "0";
    final newID = (int.parse(lastID) + 1).toString();
    return newID;
  }

  @override
  Future<Result<Customer, String>> createCustomer(Customer customer) async {
    try {
      final doc = await _database.createDocument(
        databaseId: "default",
        collectionId: 'customers',
        documentId: customer.id,
        data: customer.toAppwrite(),
      );

      return Success(Customer.fromAppwrite(doc));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Customer, String>> getCustomer(String id) async {
    try {
      final doc = await _database.getDocument(
        databaseId: "default",
        collectionId: 'customers',
        documentId: id,
      );

      return Success(Customer.fromAppwrite(doc));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteCustomer(String id) async {
    try {
      await _database.deleteDocument(
        databaseId: "default",
        collectionId: 'customers',
        documentId: id,
      );

      return Success(null);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Customer, String>> updateCustomer(Customer customer) async {
    try {
      final doc = await _database.updateDocument(
        databaseId: "default",
        collectionId: 'customers',
        documentId: customer.id,
        data: customer.toAppwrite(),
      );

      return Success(Customer.fromAppwrite(doc));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }
}
