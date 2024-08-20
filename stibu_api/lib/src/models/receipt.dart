import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:stibu_api/src/models/common.dart';
import 'package:stibu_api/src/models/invoice_number.dart';

class Receipt extends AppwriteModel {
  final String title;
  final String? description;
  final int amount;
  final bool readOnly;
  final String invoiceNumber;
  final String? order;

  Receipt._({
    required this.title,
    this.description,
    required this.amount,
    this.readOnly = false,
    required this.invoiceNumber,
    this.order,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  });

  factory Receipt({
    required String title,
    String? description,
    required int amount,
    bool readOnly = false,
    required InvoiceNumber invoiceNumber,
    String? order,
  }) {
    return Receipt._(
      title: title,
      description: description,
      amount: amount,
      readOnly: readOnly,
      invoiceNumber: invoiceNumber.$id,
      order: order,
      $id: ID.unique(),
      $collectionId: "receipts",
      $databaseId: "default",
      $createdAt: DateTime.now(),
      $updatedAt: DateTime.now(),
      $permissions: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'readOnly': readOnly,
      'invoiceNumber': invoiceNumber,
      'order': order,
    };
  }

  factory Receipt.fromAppwrite(Document doc) {
    final data = doc.data;
    return Receipt._(
      title: data['title'],
      description: data['description'],
      amount: data['amount'],
      readOnly: data['readOnly'],
      invoiceNumber: data['invoiceNumber'],
      order: data['order'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.from(doc.$permissions),
    );
  }

  Receipt copyWith({
    String? title,
    String? description,
    int? amount,
    bool? readOnly,
    String? invoiceNumber,
    String? order,
  }) {
    return Receipt._(
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      readOnly: readOnly ?? this.readOnly,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      order: order ?? this.order,
      $id: $id,
      $collectionId: $collectionId,
      $databaseId: $databaseId,
      $createdAt: $createdAt,
      $updatedAt: $updatedAt,
      $permissions: $permissions,
    );
  }
}
