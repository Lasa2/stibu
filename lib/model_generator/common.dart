String generateCommon() {
  return '''
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:get_it/get_it.dart';

abstract class AppwriteModel<T> {
  final String \$id;
  final String \$collectionId;
  final String \$databaseId;
  final DateTime \$createdAt;
  final DateTime \$updatedAt;
  final List<String> \$permissions;

  bool get canRead => \$permissions.any((e) => e.contains("read"));
  bool get canUpdate => \$permissions.any((e) => e.contains("update"));
  bool get canDelete => \$permissions.any((e) => e.contains("delete"));

  bool get canReadUpdate => canRead && canUpdate;

  AppwriteModel({
    required this.\$id,
    required this.\$collectionId,
    required this.\$databaseId,
    required this.\$createdAt,
    required this.\$updatedAt,
    required this.\$permissions,
  });

  Map<String, dynamic> toJson();

  T copyWith({
    String? \$id,
    String? \$collectionId,
    String? \$databaseId,
    DateTime? \$createdAt,
    DateTime? \$updatedAt,
    List<String>? \$permissions,
  });

  @override
  String toString() {
    return toJson().toString();
  }
}

class AppwriteClient {
  final Client client;
  late final Account account = Account(client);
  late final Databases databases = Databases(client);
  late final Realtime realtime = Realtime(client);
  late final Functions functions = Functions(client);
  late final Avatars avatars = Avatars(client);

  String? overrideDatabaseId;

  AppwriteClient(this.client);

  Future<Result<(int, List<T>), String>> page<T extends AppwriteModel<T>>(
      String databaseId,
      String collectionId,
      T Function(Document doc) fromAppwrite,
      {int limit = 25,
      int? offset,
      T? last}) async {
    assert(limit > 0);
    assert(offset != null && offset >= 0 || last != null);
    try {
      final response = await databases.listDocuments(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        queries: [
          Query.limit(limit),
          if (offset != null) Query.offset(offset),
          if (last != null) Query.cursorAfter(last.\$id),
        ],
      );

      return Success((
        response.total,
        response.documents.map((e) => fromAppwrite(e)).toList()
      ));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to list documents");
    }
  }

  Future<Result<T, String>> get<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, String documentId, T Function(Document doc) fromAppwrite) async {
    try {
      final response = await databases.getDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to get document");
    }
  }

  Future<Result<T, String>> create<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, T Function(Document doc) fromAppwrite, T model) async {
    try {
      final response = await databases.createDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toJson(),
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to create document");
    }
  }

  Future<Result<T, String>> update<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, T Function(Document doc) fromAppwrite, T model) async {
    try {
      final response = await databases.updateDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toJson(),
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to update document");
    }
  }

  Future<Result<void, String>> delete(String databaseId, String collectionId, String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to delete document");
    }
  }
}

class CollectionInfo {
  final String \$id;
  final List<String> \$permissions;
  final String databaseId;
  final String name;
  final bool enabled;
  final bool documentSecurity;

  const CollectionInfo({
    required this.\$id,
    required this.\$permissions,
    required this.databaseId,
    required this.name,
    required this.enabled,
    required this.documentSecurity,
  });
}

enum RelationshipType {
  oneToOne,
  oneToMany,
  manyToOne,
  manyToMany,
}

enum OnDelete {
  setNull,
  cascade,
  restrict,
}

enum Side {
  parent,
  child,
}

class Relationship {
  final bool required;
  final bool array;
  final String relatedCollection;
  final RelationshipType relationType;
  final bool twoWay;
  final String? twoWayKey;
  final OnDelete onDelete;
  final Side side;

  Relationship({
    this.required = false,
    this.array = false,
    required this.relatedCollection,
    required this.relationType,
    this.twoWay = false,
    this.twoWayKey,
    required this.onDelete,
    required this.side,
  });
}
''';
}
