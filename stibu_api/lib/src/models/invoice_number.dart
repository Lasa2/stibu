import 'package:appwrite/models.dart';
import 'package:stibu_api/src/models/common.dart';

class InvoiceNumber extends AppwriteModel {
  final String invoiceNumber;
  final bool isCanceled;
  final DateTime date;
  final String receipt;

  InvoiceNumber._({
    required this.invoiceNumber,
    this.isCanceled = false,
    required this.date,
    required this.receipt,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'isCanceled': isCanceled,
      'date': date.toIso8601String(),
      'receipt': receipt,
    };
  }

  factory InvoiceNumber.fromAppwrite(Document doc) {
    final data = doc.data;
    return InvoiceNumber._(
      invoiceNumber: data['invoiceNumber'],
      isCanceled: data['isCanceled'],
      date: DateTime.parse(data['date']),
      receipt: data['receipt'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.from(doc.$permissions),
    );
  }

  InvoiceNumber copyWith({
    String? invoiceNumber,
    bool? isCanceled,
    DateTime? date,
    String? receipt,
  }) {
    return InvoiceNumber._(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      isCanceled: isCanceled ?? this.isCanceled,
      date: date ?? this.date,
      receipt: receipt ?? this.receipt,
      $id: $id,
      $collectionId: $collectionId,
      $databaseId: $databaseId,
      $createdAt: $createdAt,
      $updatedAt: $updatedAt,
      $permissions: $permissions,
    );
  }
}
