import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stibu_api/src/common.dart';
import 'package:stibu_api/src/models/receipt.dart';
import 'package:stibu_api/src/repository/accounts.dart';

abstract class ReceiptRepository {
  ValueStream<List<Receipt>> get receipts;

  Future<List<Receipt>> getReceipts();
  Future<Result<Receipt, String>> getReceipt(String id);
  Future<Result<Receipt, String>> createReceipt(Receipt receipt);
  Future<Result<Receipt, String>> updateReceipt(Receipt receipt);
  Future<Result<void, String>> deleteReceipt(String id);
}

class ReceiptRepositoryAppwrite implements ReceiptRepository {
  var _receipts = BehaviorSubject<List<Receipt>>.seeded([]);
  final _collector = Collector<Receipt>();

  @override
  ValueStream<List<Receipt>> get receipts => _receipts.stream;

  final Databases _database;
  final Realtime _realtime;
  RealtimeSubscription? _subscription;

  ReceiptRepositoryAppwrite(
    this._database,
    this._realtime,
    AccountsRepositoryAppwrite _accountsRepository,
  ) {
    _accountsRepository.isAuthenticated.listen((isAuthenticated) async {
      if (isAuthenticated != null) {
        await _subscribeReceipts();
      } else {
        await _unsubscribeReceipts();
      }
    });
  }

  Future<void> _subscribeReceipts() async {
    _receipts = BehaviorSubject<List<Receipt>>.seeded([]);

    final receipts = await getReceipts();
    _collector.addItems(receipts);
    _receipts.add(_collector.items);

    _subscription = _realtime.subscribe(
      ["databases.default.collections.receipts.documents"],
    );
    _subscription!.stream.listen((data) {
      final event = data.events.first.split(".").last;
      switch (event) {
        case "create":
          break;
        case "update":
          final doc = Document.fromMap(data.payload);
          final receipt = Receipt.fromAppwrite(doc);
          _collector.addItem(receipt);
          _receipts.add(_collector.items);
          break;
        case "delete":
          final id = data.payload["\$id"];
          _collector.removeItem(id);
          _receipts.add(_collector.items);
          break;
      }
    });
  }

  Future<void> _unsubscribeReceipts() async {
    await _subscription?.close();
    _receipts.close();
  }

  @override
  Future<List<Receipt>> getReceipts() async {
    final response = await _database.listDocuments(
      databaseId: "default",
      collectionId: "receipts",
    );
    return response.documents.map((doc) => Receipt.fromAppwrite(doc)).toList();
  }

  @override
  Future<Result<Receipt, String>> getReceipt(String id) async {
    try {
      final response = await _database.getDocument(
        databaseId: "default",
        collectionId: "receipts",
        documentId: id,
      );
      return Success(Receipt.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get receipt");
    }
  }

  @override
  Future<Result<Receipt, String>> createReceipt(Receipt receipt) async {
    try {
      final response = await _database.createDocument(
        databaseId: "default",
        collectionId: "receipts",
        documentId: receipt.$id,
        data: receipt.toJson(),
      );
      return Success(Receipt.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to create receipt");
    }
  }

  @override
  Future<Result<Receipt, String>> updateReceipt(Receipt receipt) async {
    try {
      final response = await _database.updateDocument(
        databaseId: "default",
        collectionId: "receipts",
        documentId: receipt.$id,
        data: receipt.toJson(),
      );
      return Success(Receipt.fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to update receipt");
    }
  }

  @override
  Future<Result<void, String>> deleteReceipt(String id) async {
    try {
      await _database.deleteDocument(
        databaseId: "default",
        collectionId: "receipts",
        documentId: id,
      );
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to delete receipt");
    }
  }
}
