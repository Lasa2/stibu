import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:result_type/result_type.dart';
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/invoices/pdf/basic_template.dart';
import 'package:stibu/main.dart';

const invoicesWithOrderDispatch = <String, Future<Document> Function(Invoices)>{
  'basic': generateBasicInvoiceWithOrder,
};

const invoicesWithoutOrderDispatch =
    <String, Future<Document> Function(Invoices)>{
  'basic': generateBasicInvoiceWithoutOrder,
};

Future<Document> getDocument(Invoices invoice) async {
  if (invoice.order == null) {
    final templatePreferences =
        (await getIt<AppwriteClient>().account.getPrefs())
            .data['invoiceTemplateWithoutOrder'];

    if (templatePreferences == null ||
        !invoicesWithoutOrderDispatch.containsKey(templatePreferences)) {
      return generateBasicInvoiceWithoutOrder(invoice);
    }

    return invoicesWithoutOrderDispatch[templatePreferences]!(invoice);
  }

  final templatePreferences = (await getIt<AppwriteClient>().account.getPrefs())
      .data['invoiceTemplateWithOrder'];

  if (templatePreferences == null ||
      !invoicesWithOrderDispatch.containsKey(templatePreferences)) {
    return generateBasicInvoiceWithOrder(invoice);
  }

  return invoicesWithOrderDispatch[templatePreferences]!(invoice);
}

Future<Result<void, String>> shareInvoice(Invoices invoice) async {
  try {
    final appwrite = getIt<AppwriteClient>();
    final preferences = (await appwrite.account.getPrefs()).data;

    final doc = await getDocument(invoice);
    final String filenamePattern = preferences['invoiceWithOrderFilename'] ??
        'Invoice {invoiceDate} - {invoiceNumber}';

    final filename = sanitizeFilename(filenamePattern
        .replaceAll('{invoiceNumber}', invoice.invoiceNumber)
        .replaceAll('{invoiceDate}',
            '${invoice.date.year}-${invoice.date.month}-${invoice.date.day}'));

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '$filename.pdf',
    );
    return Success(null);
  } catch (e) {
    return Failure(e.toString());
  }
}
