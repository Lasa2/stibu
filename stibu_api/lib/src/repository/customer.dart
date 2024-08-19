import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stibu_api/src/common.dart';
import 'package:stibu_api/src/models/customer.dart';
import 'package:stibu_api/src/repository/accounts.dart';

abstract class CustomerRepository<T extends Customer> {
  ValueStream<List<T>> get customers;

  Future<List<Customer>> getCustomers();
  Future<Result<T, String>> getCustomer(String id);
  Future<Result<int, String>> newID();
  Future<Result<Customer, String>> createCustomer(T customer);
  Future<Result<T, String>> updateCustomer(T customer);
  Future<Result<void, String>> deleteCustomer(String id);
}

class CustomerRepositoryAppwrite extends CustomerRepository<CustomerAppwrite> {
  var _customers = BehaviorSubject<List<CustomerAppwrite>>.seeded([]);
  final _collector = Collector<CustomerAppwrite>();

  @override
  ValueStream<List<CustomerAppwrite>> get customers => _customers.stream;

  final Databases _database;
  final Realtime _realtime;
  final AccountsRepositoryAppwrite _accountsRepository;
  RealtimeSubscription? _subscription;

  CustomerRepositoryAppwrite(
    this._database,
    this._realtime,
    this._accountsRepository,
  ) {
    _accountsRepository.isAuthenticated.listen((isAuthenticated) async {
      if (isAuthenticated != null) {
        await _subscribeCustomers();
      } else {
        await _unsubscribeCustomers();
      }
    });
  }

  Future<void> _subscribeCustomers() async {
    _customers = BehaviorSubject<List<CustomerAppwrite>>.seeded([]);

    final customers = await getCustomers();
    _collector.addItems(customers);
    _customers.add(_collector.items);

    _subscription = _realtime.subscribe(
      ["databases.default.collections.customers.documents"],
    );
    _subscription!.stream.listen((data) {
      final event = data.events.first.split(".").last;
      switch (event) {
        case "create":
        case "update":
          final doc = Document.fromMap(data.payload);
          final customer = CustomerAppwrite.fromAppwrite(doc);
          _collector.addItem(customer);
          _customers.add(_collector.items);
          break;
        case "delete":
          final doc = Document.fromMap(data.payload);
          final customer = CustomerAppwrite.fromAppwrite(doc);
          _collector.removeItem(customer.$id);
          _customers.add(_collector.items);
          break;
      }
    });
  }

  Future<void> _unsubscribeCustomers() async {
    await _subscription?.close();
    await _customers.close();
  }

  @override
  Future<List<CustomerAppwrite>> getCustomers() async {
    final response = await _database.listDocuments(
      databaseId: "default",
      collectionId: 'customers',
    );

    return response.documents
        .map((doc) => CustomerAppwrite.fromAppwrite(doc))
        .toList();
  }

  @override
  Future<Result<CustomerAppwrite, String>> getCustomer(String id) async {
    try {
      final doc = await _database.getDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: id,
      );

      return Success(CustomerAppwrite.fromAppwrite(doc));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get customer");
    }
  }

  @override
  Future<Result<int, String>> newID() async {
    try {
      final doc = await _database.listDocuments(
        databaseId: "default",
        collectionId: "customers",
        queries: [
          Query.orderDesc("\$id"),
          Query.limit(1),
        ],
      );

      final lastId = doc.documents.isEmpty
          ? 0
          : int.parse(
              (doc.documents.first.data['\$id'] as String).split("-").last);
      final newID = lastId + 1;

      return Success(newID);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to generate new ID");
    }
  }

  @override
  Future<Result<CustomerAppwrite, String>> createCustomer(
      Customer customer) async {
    try {
      final result = await (_accountsRepository.user);
      if (result.isFailure) {
        return Failure("User not authenticated");
      }

      final id = "${result.success.$id}-${customer.id}";
      final response = await _database.createDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: id,
        data: customer.toJson(),
      );

      return Success(CustomerAppwrite.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to create customer");
    }
  }

  @override
  Future<Result<CustomerAppwrite, String>> updateCustomer(
      CustomerAppwrite customer) async {
    try {
      final response = await _database.updateDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: customer.$id,
        data: customer.toJson(),
      );

      return Success(CustomerAppwrite.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to update customer");
    }
  }

  @override
  Future<Result<void, String>> deleteCustomer(String id) async {
    try {
      await _database.deleteDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: id,
      );

      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to delete customer");
    }
  }
}
