import 'package:appwrite/appwrite.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/main.dart';

Future<Result<int, String>> newCustomerId() async {
  final appwrite = getIt<AppwriteClient>();
  try {
    final doc = await appwrite.databases.listDocuments(
      databaseId: Customers.collectionInfo.databaseId,
      collectionId: Customers.collectionInfo.$id,
      queries: [
        Query.orderDesc('id'),
        Query.limit(1),
      ],
    );

    final lastId =
        doc.documents.isEmpty ? 0 : doc.documents.first.data['id'] as int;
    return Success(lastId + 1);
  } on AppwriteException catch (e) {
    return Failure(e.message ?? 'Failed to generate customer ID');
  }
}

String _incrementLetterCode(String letters) {
  // Letters are uppercase
  // letters is a string of 3 uppercase letters

  final List<int> codeUnits = letters.codeUnits.toList();

  // Iterate over the code units in reverse order
  for (int idx = codeUnits.length - 1; idx >= 0; idx--) {
    final int codeUnit = codeUnits[idx];

    // Increment the code unit
    codeUnits[idx] = codeUnit + 1;

    // If the code unit is now out of range, reset it to 'A' and continue
    if (codeUnits[idx] > 'Z'.codeUnitAt(0)) {
      codeUnits[idx] = 'A'.codeUnitAt(0);
    } else {
      // If the code unit is within range, we're done
      break;
    }
  }

  return String.fromCharCodes(codeUnits);
}

Future<Result<String, String>> newExpenseNumber([DateTime? date]) async {
  final utcDate = date?.toUtc() ?? DateTime.now().toUtc();
  final appwrite = getIt<AppwriteClient>();
  try {
    final latestExpense = await appwrite.databases.listDocuments(
      databaseId: Expenses.collectionInfo.databaseId,
      collectionId: Expenses.collectionInfo.$id,
      queries: [
        Query.orderDesc('expenseNumber'),
        Query.limit(1),
      ],
    );

    late final String newId;
    if (latestExpense.documents.isNotEmpty) {
      // Format: YYYY-XXX where XXX is letters
      final lastId = latestExpense.documents.first.data['expenseNumber'];

      final List<String> parts = lastId.split('-');
      final String year = parts[0];
      final String letters = parts[1];

      final currentYear = utcDate.year.toString();

      newId = year == currentYear
          ? '$year-${_incrementLetterCode(letters)}'
          : '$currentYear-00A';
    } else {
      newId = '${utcDate.year}-00A';
    }

    return Success(newId);
  } on AppwriteException catch (e) {
    return Failure(e.message ?? 'Failed to generate expense number');
  }
}

Future<Result<String, String>> newInvoiceNumber([DateTime? date]) async {
  final utcDate = date?.toUtc() ?? DateTime.now().toUtc();
  final appwrite = getIt<AppwriteClient>();
  try {
    final latestInvoices = await appwrite.databases.listDocuments(
      databaseId: Invoices.collectionInfo.databaseId,
      collectionId: Invoices.collectionInfo.$id,
      queries: [
        Query.orderDesc('invoiceNumber'),
        Query.limit(1),
      ],
    );

    late final String newId;
    if (latestInvoices.documents.isNotEmpty) {
      // Get the latest invoice number
      // Format: YYYY-XXXX
      final String latestInvoiceNumber =
          latestInvoices.documents.first.data['invoiceNumber'];

      // Split the invoice number into year and number
      final List<String> parts = latestInvoiceNumber.split('-');
      final String year = parts[0];
      final String number = parts[1];

      // Get the current year
      final String currentYear = utcDate.year.toString();

      // If the current year is the same as the year in the latest invoice number
      // Increment the number by 1
      // Otherwise, reset the number to 1
      newId = currentYear == year
          ? '$currentYear-${(int.parse(number) + 1).toString().padLeft(4, '0')}'
          : '$currentYear-0001';
    } else {
      // If there are no invoices yet, create the first invoice number
      newId = '${utcDate.year}-0001';
    }

    return Success(newId);
  } on AppwriteException catch (e) {
    return Failure(e.message ?? 'Failed to generate new ID');
  }
}
