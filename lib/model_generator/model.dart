import 'package:stibu/model_generator/attributes.dart';
import 'package:stibu/model_generator/collections.dart';

String capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}

String generateEnums(List<AttributeInfo> attributeInfos) {
  return attributeInfos
      .whereType<AttributeInfoEnum>()
      .map(
        (e) => '''
enum ${capitalize(e.name)} {
  ${e.elements.map((v) => '$v,').join('\n\t')}
}
  ''',
      )
      .join('\n\n');
}

String generateClass(CollectionInfo collection) {
  final className = capitalize(collection.name);
  final List<AttributeInfo> attributeInfos = collection.attributes
    ..sort((a, b) => a.name.compareTo(b.name));

  final asserts =
      attributeInfos.expand((e) => generateAsserts(e)).join(',\n\t\t\t\t');

  return '''${generateEnums(attributeInfos)}
class $className extends AppwriteModel<$className> {
  static const collectionInfo = CollectionInfo(
    \$id: '${collection.$id}',
    \$permissions: [${collection.$permissions.map((e) => "'$e'").join(', ')}],
    databaseId: '${collection.databaseId}',
    name: '${collection.name}',
    enabled: ${collection.enabled},
    documentSecurity: ${collection.documentSecurity},
  );

  ${attributeInfos.map(generateField).join('\n\t')}

  $className._({
    ${attributeInfos.map(generateConstructorField).join(',\n\t\t')},
    required super.\$id,
    required super.\$collectionId,
    required super.\$databaseId,
    required super.\$createdAt,
    required super.\$updatedAt,
    required super.\$permissions,
  })${asserts.isNotEmpty ? '  : $asserts' : ''};

  factory $className({
    ${attributeInfos.map(generateNamedConstructorField).join(',\n\t\t')},
  }) {
    return $className._(
      ${attributeInfos.map(generateNamedConstructorFieldAssignment).join(',\n\t\t\t')},
      \$id: ID.unique(),
      \$collectionId: collectionInfo.\$id,
      \$databaseId: collectionInfo.databaseId,
      \$createdAt: DateTime.now().toUtc(),
      \$updatedAt: DateTime.now().toUtc(),
      \$permissions: collectionInfo.\$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ${attributeInfos.map(generateToJsonField).join(',\n\t\t\t')}
    };
  }

  @override
  Map<String, dynamic> toAppwrite({
    bool isChild = false,
    bool includeRelations = true,
  }) {
    return {
      ${attributeInfos.map(generateToAppwriteField).join(',\n\t\t\t')},
      if (isChild) '\\\$id': \$id,
    };
  }

  @override
  $className copyWith({
    ${attributeInfos.map(generateCopyWithField).join(',\n\t\t')},
    String? \$id,
    String? \$collectionId,
    String? \$databaseId,
    DateTime? \$createdAt,
    DateTime? \$updatedAt,
    List<String>? \$permissions,
  }) {
    return $className._(
      ${attributeInfos.map(generateCopyWithFieldAssignment).join(',\n\t\t\t')},
      \$id: \$id ?? this.\$id,
      \$collectionId: \$collectionId ?? this.\$collectionId,
      \$databaseId: \$databaseId ?? this.\$databaseId,
      \$createdAt: \$createdAt ?? this.\$createdAt,
      \$updatedAt: \$updatedAt ?? this.\$updatedAt,
      \$permissions: \$permissions ?? this.\$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {${containsList(attributeInfos) ? '\n\t\tfinal eq = const ListEquality().equals;' : ''}
    return other is $className &&
      ${attributeInfos.map(generateEqualsFields).join(' &&\n\t\t\t')} &&
      other.\$id == \$id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      ${attributeInfos.map(generateHashCodeField).join(',\n\t\t\t')},
      \$id,
    ]);
  }

  factory $className.fromAppwrite(Document doc) {
    return $className._(
      ${attributeInfos.map(generateFromAppwriteField).join(',\n\t\t\t')},
      \$id: doc.\$id,
      \$collectionId: doc.\$collectionId,
      \$databaseId: doc.\$databaseId,
      \$createdAt: DateTime.parse(doc.\$createdAt),
      \$updatedAt: DateTime.parse(doc.\$updatedAt),
      \$permissions: List<String>.unmodifiable(doc.\$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<$className>), String>> page({
    int limit = 25,
    int? offset,
    $className? last,
  }) async {
    return client.page<$className>(
      collectionInfo.databaseId,
      collectionInfo.\$id,
      $className.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<$className, String>> get(String id) async {
    return client.get<$className>(
      collectionInfo.databaseId,
      collectionInfo.\$id,
      id,
      $className.fromAppwrite,
    );
  }

  Future<Result<$className, String>> create() async {
    return client.create<$className>(
      collectionInfo.databaseId,
      collectionInfo.\$id,
      $className.fromAppwrite,
      this,
    );
  }

  Future<Result<$className, String>> update() async {
    return client.update<$className>(
      collectionInfo.databaseId,
      collectionInfo.\$id,
      $className.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.\$id,
      \$id,
    );
  }
}
''';
}
