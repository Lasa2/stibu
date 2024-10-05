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
  Currency get productsTotal =>
      products?.fold<Currency>(
        Currency.zero,
        (value, product) => value + product.total,
      ) ??
      Currency.zero;

  Currency get couponsTotal =>
      coupons?.fold<Currency>(
        Currency.zero,
        (value, coupon) => value + coupon.amount.currency,
      ) ??
      Currency.zero;

  Currency get total => productsTotal - couponsTotal;

  Future<Result<Invoices, String>> createInvoice({
    DateTime? date,
    String? note,
  }) async {
    final appwrite = getIt<AppwriteClient>();
    try {
      final invoiceId = await newInvoiceNumber(date);
      if (invoiceId.isFailure) return Failure(invoiceId.failure);
      final user = await appwrite.account.get();

      final permissions = [
        Permission.read(Role.user(user.$id)),
      ];

      final doc = await appwrite.databases.createDocument(
        databaseId: Invoices.databaseId,
        collectionId: Invoices.collectionInfo.$id,
        documentId: ID.unique(),
        data: {
          "invoiceNumber": invoiceId.success,
          'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
          "name": "Invoice ${invoiceId.success}",
          "amount": total.asInt,
          "notes": note,
          "order": $id,
        },
        permissions: permissions,
      );

      // Set order, orderProducts and orderCoupons permissions to read-only
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
          'coupons': coupons?.map((coupon) {
            return {
              '\$id': coupon.$id,
              '\$permissions': permissions,
            };
          }).toList(),
        },
      );

      return Success(Invoices.fromAppwrite(doc));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to create invoice");
    }
  }

  Future<Result<Orders, String>> addCoupon(OrderCoupons coupon) async {
    final newCoupons = <OrderCoupons>[...(coupons ?? []), coupon];
    final result = await copyWith(coupons: newCoupons).update();
    if (result.isFailure) return Failure(result.failure);

    return Success(result.success);
  }

  Future<Result<Orders, String>> deleteCoupon(OrderCoupons coupon) async {
    final newCoupons =
        copyWith(coupons: coupons?.where((c) => c.$id != coupon.$id).toList());

    final order = await copyWith(coupons: newCoupons.coupons).update();
    if (order.isFailure) return Failure(order.failure);

    final result = await coupon.delete();
    if (result.isFailure) return Failure(result.failure);

    return Success(order.success);
  }

  Future<Result<Orders, String>> updateCoupon(OrderCoupons coupon) async {
    final newCoupons = coupons?.map((c) {
      if (c.$id == coupon.$id) return coupon;
      return c;
    }).toList();

    final result = await copyWith(coupons: newCoupons).update();
    if (result.isFailure) return Failure(result.failure);

    return Success(result.success);
  }

  Future<Result<Orders, String>> addProduct(OrderProducts product) async {
    final newProducts = <OrderProducts>[...(products ?? []), product];
    final result = await copyWith(products: newProducts).update();
    if (result.isFailure) return Failure(result.failure);

    return Success(result.success);
  }

  Future<Result<Orders, String>> deleteProduct(OrderProducts product) async {
    final newProducts = copyWith(
      products: products?.where((p) => p.$id != product.$id).toList(),
    );

    final order = await copyWith(products: newProducts.products).update();
    if (order.isFailure) return Failure(order.failure);

    final result = await product.delete();
    if (result.isFailure) return Failure(result.failure);

    return Success(order.success);
  }

  Future<Result<Orders, String>> updateProduct(OrderProducts product) async {
    final newProducts = products?.map((p) {
      if (p.$id == product.$id) return product;
      return p;
    }).toList();

    final result = await copyWith(products: newProducts).update();
    if (result.isFailure) return Failure(result.failure);

    return Success(result.success);
  }
}
