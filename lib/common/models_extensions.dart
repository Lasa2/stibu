import 'package:appwrite/appwrite.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/common/new_ids.dart';
import 'package:stibu/main.dart';

extension OrderProductsExtension on OrderProducts {
  Currency get total => price.currency * quantity;
}

extension ProductsExtension on Products {
  String? get imageUrl => images.isEmpty
      ? null
      : "https://res.cloudinary.com/stampin-up/image/upload/q_auto:best,f_auto/bo_1px_solid_rgb:cccccc/w_3200,q_60,f_auto,d_missing_image.png/v1/prod/images/default-source/product-image/${images.first}";
}

extension CurrencyExtensions on int {
  Currency get currency => Currency(this);
}

extension CustomersExtensions on Customers {
  String get address => '$street, $zip $city';
  String get zipWithCityFormatted => '$zip $city';
}

extension OrdersExtensions on Orders {
  Currency get total =>
      products?.fold<Currency>(
          Currency.zero, (value, product) => value + product.total) ??
      Currency.zero;

  Future<Result<Invoices, String>> createInvoice([DateTime? date]) async {
    final appwrite = getIt<AppwriteClient>();
    try {
      final invoiceId = await newInvoiceNumber(date);
      if (invoiceId.isFailure) return Failure(invoiceId.failure);
      final user = await appwrite.account.get();

      final doc = await appwrite.databases.createDocument(
        databaseId: Invoices.databaseId,
        collectionId: Invoices.collectionInfo.$id,
        documentId: invoiceId.success,
        data: {
          "invoiceNumber": invoiceId.success,
          'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
          "name": "Invoice ${invoiceId.success}",
          "amount": total.asInt,
          "order": $id,
          '\$permissions': [
            Permission.read(Role.user(user.$id)),
          ]
        },
      );

      // Set order and orderProducts permissions to read-only
      final permissions = [
        Permission.read(Role.user(user.$id)),
      ];

      await appwrite.databases.updateDocument(
          databaseId: Orders.databaseId,
          collectionId: Orders.collectionInfo.$id,
          documentId: $id,
          permissions: permissions,
          data: {
            'products': products?.map((product) {
              return {
                '\$id': product.$id,
                '\$permissions': permissions,
              };
            }).toList(),
          });

      return Success(Invoices.fromAppwrite(doc));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to create invoice");
    }
  }
}
