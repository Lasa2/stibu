import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stibu_api/src/models/common.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
abstract class Customer extends RefModel with _$Customer {
  const Customer._();

  @override
  String get ref => id;
  String get zipWithCityFormatted => zip != null && city != null
      ? '$zip $city'
      : zip != null
          ? zip.toString()
          : city ?? '';
  String get address => '$street, $zip $city';

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
    final id = doc.$id.split("-").last;
    return Customer.fromJson({
      ...data,
      'id': id,
    });
  }

  Map<String, dynamic> toAppwrite() => {
        'name': name,
        'email': email,
        'phone': phone,
        'street': street,
        'zip': zip,
        'city': city,
      };
}
