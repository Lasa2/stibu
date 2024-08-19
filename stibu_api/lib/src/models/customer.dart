import 'package:appwrite/models.dart';
import 'package:stibu_api/src/models/common.dart';

class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? street;
  final int? zip;
  final String? city;

  String get address => '$street, $zip $city';
  String get zipWithCityFormatted => '$zip $city';

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.street,
    this.zip,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'street': street,
        'zip': zip,
        'city': city,
      };

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? street,
    int? zip,
    String? city,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      zip: zip ?? this.zip,
      city: city ?? this.city,
    );
  }
}

class CustomerAppwrite extends Customer implements AppwriteModel {
  @override
  final String $id;
  @override
  final String $collectionId;
  @override
  final String $databaseId;
  @override
  final DateTime $createdAt;
  @override
  final DateTime $updatedAt;
  @override
  final List<String> $permissions;

  CustomerAppwrite._({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.street,
    super.zip,
    super.city,
    required this.$id,
    required this.$collectionId,
    required this.$databaseId,
    required this.$createdAt,
    required this.$updatedAt,
    required this.$permissions,
  });

  factory CustomerAppwrite.fromAppwrite(Document doc) {
    final data = doc.data;
    return CustomerAppwrite._(
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

  @override
  CustomerAppwrite copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? street,
    int? zip,
    String? city,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return CustomerAppwrite._(
      id: id ?? super.id,
      name: name ?? super.name,
      email: email ?? super.email,
      phone: phone ?? super.phone,
      street: street ?? super.street,
      zip: zip ?? super.zip,
      city: city ?? super.city,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  CustomerAppwrite copyFromCustomer(Customer customer) {
    return CustomerAppwrite._(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      street: customer.street,
      zip: customer.zip,
      city: customer.city,
      $id: $id,
      $collectionId: $collectionId,
      $databaseId: $databaseId,
      $createdAt: $createdAt,
      $updatedAt: $updatedAt,
      $permissions: $permissions,
    );
  }
}
