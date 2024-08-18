import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu_api/src/common.dart';
import 'package:stibu_api/src/models/customer.dart';
import 'package:stibu_api/src/repository/accounts.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> get customers;

  Future<List<Customer>> getCustomers();
  Future<Result<Customer, String>> getCustomer(String id);
  Future<String> newID();
  Future<Result<Customer, String>> createCustomer(Customer customer);
  Future<Result<Customer, String>> updateCustomer(Customer customer);
  Future<Result<void, String>> deleteCustomer(String id);
}

class CustomerRepositoryAppwrite implements CustomerRepository {
  final Databases _database;
  final Realtime _realtime;
  final AccountsRepositoryAppwrite _accountsRepository;

  final _collector = CollectStream<Customer>();
  RealtimeSubscription? _subscription;

  CustomerRepositoryAppwrite(
    this._database,
    this._realtime,
    this._accountsRepository,
  ) {
    if (_accountsRepository.isAuthenticated) {
      _subscribeCustomers();
    }

    _accountsRepository.isAuthenticatedStream.listen((isAuthenticated) async {
      if (isAuthenticated) {
        await _subscribeCustomers();
      } else {
        await _unsubscribeCustomers();
      }
    });
  }

  Future<void> _subscribeCustomers() async {
    final customers = await getCustomers();
    _collector.addItems(customers);

    _subscription = _realtime.subscribe(
      ["databases.default.collections.customers.documents"],
    );
    _subscription!.stream.listen((data) {
      final event = data.events.first.split(".").last;
      switch (event) {
        case "create":
        case "update":
          final doc = Document.fromMap(data.payload);
          final customer = Customer.fromAppwrite(doc);
          _collector.addItem(customer);
          break;
        case "delete":
          final id = data.payload["\$id"];
          _collector.removeItem(id);
          break;
      }
    });
  }

  Future<void> _unsubscribeCustomers() async {
    await _subscription?.close();
    _collector.clear();
  }

  @override
  Stream<List<Customer>> get customers => _collector.stream;

  @override
  Future<List<Customer>> getCustomers() async {
    final response = await _database.listDocuments(
      databaseId: "default",
      collectionId: "customers",
    );

    return response.documents.map((doc) => Customer.fromAppwrite(doc)).toList();
  }

  @override
  Future<Result<Customer, String>> getCustomer(String id) async {
    try {
      final response = await _database.getDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: id,
      );

      return Success(Customer.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get customer");
    }
  }

  @override
  Future<String> newID() async {
    final doc = await _database.listDocuments(
      databaseId: "default",
      collectionId: "customers",
      queries: [
        Query.orderDesc("\$id"),
        Query.limit(1),
      ],
    );

    final lastID = doc.documents.firstOrNull?.$id.split("-").last ?? "0";
    final newID = (int.parse(lastID) + 1).toString();

    return newID;
  }

  @override
  Future<Result<Customer, String>> createCustomer(Customer customer) async {
    try {
      final user = await _accountsRepository.user;
      final response = await _database.createDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: "${user.$id}-${customer.id}",
        data: customer.toAppwrite(),
      );

      return Success(Customer.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to create customer");
    }
  }

  @override
  Future<Result<Customer, String>> updateCustomer(Customer customer) async {
    try {
      final user = await _accountsRepository.user;
      final response = await _database.updateDocument(
        databaseId: "default",
        collectionId: "customers",
        documentId: "${user.$id}-${customer.id}",
        data: customer.toAppwrite(),
      );

      return Success(Customer.fromAppwrite(response));
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
