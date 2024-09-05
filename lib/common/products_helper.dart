import 'dart:convert';

import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/currency.dart';

Products createUnlistedProduct(
  int id,
  String title,
  Currency itemPrice,
) {
  return Products(
    id: id,
    itemPrice: itemPrice.asInt,
    qtyLimit: 99,
    originalItemPrice: 0,
    formattedItemPrice: itemPrice.format(),
    formattedOriginalItemPrice: Currency.zero.format(),
    hasSalePrice: false,
    launchDate: DateTime.now(),
    endSaleDate: DateTime.now(),
    beginSaleDate: DateTime.now(),
    slug: title.toLowerCase().replaceAll(' ', '-'),
    images: [],
    title: title,
    description: '',
    inventoryStatus: 'unlisted',
    culture: 'de-de',
    color: [],
    canBePurchased: false,
    exclusiveTo: [],
    categorySlugs: [],
    alternateId: null,
    replacementForItemId: null,
    hoverImage: null,
    metaDescription: null,
    metaTitle: null,
    isCommissionable: false,
    excludeFrom: [],
    languages: [],
    qualifier: [],
    lifeCycleStates: [],
    offeringType: 'product',
  );
}

final _unescape = HtmlUnescape();

Products _productsFromJson(Map<String, dynamic> json) => Products(
      id: int.parse(json['id']),
      itemPrice: Currency.fromDouble(json['itemPrice']).asInt,
      qtyLimit: json['qtyLimit'],
      originalItemPrice: Currency.fromDouble(json['originalItemPrice']).asInt,
      formattedItemPrice: json['formattedItemPrice'],
      formattedOriginalItemPrice: json['formattedOriginalItemPrice'],
      hasSalePrice: json['hasSalePrice'],
      launchDate: DateTime.parse(json['launchDate']),
      endSaleDate: DateTime.parse(json['endSaleDate']),
      beginSaleDate: DateTime.parse(json['beginSaleDate']),
      slug: json['slug'],
      images: List<String>.unmodifiable(json['images']),
      title: json['title'],
      description: _unescape
          .convert(json['description'])
          .replaceAll("<br />", "")
          .replaceAll("<br/>", "\n"),
      inventoryStatus: json['inventoryStatus'],
      culture: json['culture'],
      color: List<String>.unmodifiable(json['color']),
      canBePurchased: json['canBePurchased'],
      exclusiveTo: List<String>.unmodifiable(json['exclusiveTo']),
      categorySlugs: List<String>.unmodifiable(json['categorySlugs']),
      alternateId: json['alternateId'],
      replacementForItemId: json.containsKey('replacmentForItemId')
          ? int.parse(json['replacementForItemId'])
          : null,
      hoverImage: json['hoverImage'],
      metaDescription: json['metaDescription'],
      metaTitle: json['metaTitle'],
      isCommissionable: json['isCommissionable'],
      excludeFrom: List<String>.unmodifiable(json['excludeFrom']),
      languages: List<String>.unmodifiable(json['languages']),
      qualifier: List<String>.unmodifiable(json['qualifier']),
      lifeCycleStates: List<String>.unmodifiable(json['lifeCycleStates']),
      offeringType: json['offeringType'],
    );

const _headers = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/116.0",
};

Future<Result<List<Products>, String>> getCurrentProducts() async {
  try {
    final uri = Uri.https("az-api.stampinup.de", "/de-de/products", {
      "page": "1",
      "pageSize": "9999",
      "category": "/shop-products",
    });

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      return Failure("Failed to fetch products");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Success(
      (data["products"] as List).map((product) {
        try {
          return _productsFromJson(product);
        } catch (e) {
          throw Exception("Failed to parse product: $e on $product");
        }
      }).toList(),
    );
  } catch (e) {
    return Failure(e.toString());
  }
}
