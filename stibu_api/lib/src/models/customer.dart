import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:stibu_api/src/models/common.dart';

class Customer extends AppwriteModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? street;
  final int? zip;
  final String? city;

  String get address => '$street, $zip $city';
  String get zipWithCityFormatted => '$zip $city';

  Customer._({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.street,
    this.zip,
    this.city,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  });

  factory Customer({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? street,
    int? zip,
    String? city,
  }) {
    return Customer._(
      id: id,
      name: name,
      email: email,
      phone: phone,
      street: street,
      zip: zip,
      city: city,
      $id: ID.unique(),
      $collectionId: "customers",
      $databaseId: "default",
      $createdAt: DateTime.now(),
      $updatedAt: DateTime.now(),
      $permissions: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'street': street,
        'zip': zip,
        'city': city,
      };

  factory Customer.fromAppwrite(Document doc) {
    final data = doc.data;
    return Customer._(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      street: data['street'],
      zip: data['zip'],
      city: data['city'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.from(doc.$permissions),
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? street,
    int? zip,
    String? city,
  }) {
    return Customer._(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      zip: zip ?? this.zip,
      city: city ?? this.city,
      $id: $id,
      $collectionId: $collectionId,
      $databaseId: $databaseId,
      $createdAt: $createdAt,
      $updatedAt: $updatedAt,
      $permissions: $permissions,
    );
  }
}
