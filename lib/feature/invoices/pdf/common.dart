import 'package:printing/printing.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/invoices/pdf/basic_template.dart';

Future<void> shareInvoice(Invoices invoice) async {
  final pdf = await generateInvoice(invoice);
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Rechnung-${invoice.invoiceNumber}.pdf',
  );
}
