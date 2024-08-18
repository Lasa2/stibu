import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stibu/common/model.dart';

part 'model.freezed.dart';
part 'model.g.dart';

@freezed
class Customer extends RefModel with _$Customer {
  String get zipWithCityFormatted => zip != null && city != null
      ? '$zip $city'
      : zip != null
          ? zip.toString()
          : city ?? '';

  @override
  String get ref => id;

  const Customer._();

  factory Customer({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? street,
    int? zip,
    String? city,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  factory Customer.fromAppwrite(Document doc) {
    final data = doc.data;
    return Customer(
      id: doc.$id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      street: data['street'],
      zip: data['zip'],
      city: data['city'],
    );
  }

  Map<String, dynamic> toAppwrite() => {
        'name': name,
        'email': email,
        'phone': phone,
        'street': street,
        'zip': zip,
        'city': city,
      };

  String get address => '$street, $zip $city';
}
