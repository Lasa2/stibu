abstract class AppwriteModel {
  final String $id;
  final String $collectionId;
  final String $databaseId;
  final DateTime $createdAt;
  final DateTime $updatedAt;
  final List<String> $permissions;

  AppwriteModel({
    required this.$id,
    required this.$collectionId,
    required this.$databaseId,
    required this.$createdAt,
    required this.$updatedAt,
    required this.$permissions,
  });
}
