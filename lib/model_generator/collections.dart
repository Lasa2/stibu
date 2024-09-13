import 'package:stibu/model_generator/attributes.dart';

class CollectionInfo {
  final String $id;
  final List<String> $permissions;
  final String databaseId;
  final String name;
  final bool enabled;
  final bool documentSecurity;
  final List<AttributeInfo> attributes;

  CollectionInfo({
    required this.$id,
    required this.$permissions,
    required this.databaseId,
    required this.name,
    required this.enabled,
    required this.documentSecurity,
    required this.attributes,
  });

  factory CollectionInfo.fromMap(
      Map<String, dynamic> map, Map<String, String> collectionIdToName) {
    return CollectionInfo(
      $id: map['\$id'],
      $permissions: List.unmodifiable(map['\$permissions']),
      databaseId: map['databaseId'],
      name: map['name'],
      enabled: map['enabled'],
      documentSecurity: map['documentSecurity'],
      attributes: (map['attributes'] as List<dynamic>)
          .map((e) => resolveAttributeInfo(
              e as Map<String, dynamic>, collectionIdToName))
          .toList(),
    );
  }
}
