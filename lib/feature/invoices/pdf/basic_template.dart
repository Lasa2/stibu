import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/models_extensions.dart';

Future<Document> generateInvoice(Invoices invoice) async {
  assert(invoice.order != null);
  assert(invoice.order!.products != null);
  assert(invoice.order!.coupons != null);

  final pdf = Document();

  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();

  pdf.addPage(Page(
    pageFormat: PdfPageFormat.a4,
    theme: ThemeData(
      defaultTextStyle: TextStyle(
        font: font,
        fontBold: fontBold,
        fontSize: 10,
      ),
    ),
    build: (context) => Column(
      children: [
        Text('Rechnung', style: Theme.of(context).header0),
        Spacer(),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(invoice.order!.customerName),
                Text(invoice.order!.street ?? ''),
                Text(
                    '${invoice.order!.zip ?? ''} ${invoice.order!.city ?? ''}'),
              ],
            ),
            Spacer(flex: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rechnungsnummer:'),
                Text('Rechnungsdatum:'),
                Text('Kundennummer:'),
                Text('Steuernummer:'),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(invoice.invoiceNumber),
                Text(invoice.date.formatDate()),
                Text(invoice.order!.customerId.toString()),
                Text('347/2360/4564'),
              ],
            ),
          ],
        ),
        Spacer(),
        Table(
            border: TableBorder.all(
              width: 0.5,
            ),
            columnWidths: {
              0: const FlexColumnWidth(1),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(0.5),
              3: const FlexColumnWidth(0.75),
              4: const FlexColumnWidth(0.75),
            },
            children: [
              TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    Text('Artikelnummer', textAlign: TextAlign.center),
                    Text('Artikelbezeichnung', textAlign: TextAlign.center),
                    Text('Menge', textAlign: TextAlign.center),
                    Text(
                      'Einzelpreis\n€',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Gesamtpreis\nBrutto €',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ]),
              for (final product in invoice.order!.products!)
                TableRow(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    Text(product.id.toString(), textAlign: TextAlign.center),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(product.title),
                    ),
                    Text(
                      product.quantity.toString(),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        product.price.currency.format(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        product.total.format(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
            ]),
        for (final coupon in invoice.order!.coupons!)
          Container(
              alignment: Alignment.centerRight,
              child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    '${coupon.name}: ${coupon.amount.currency.format()}',
                  ))),
        Container(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                  ),
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  'Gesamtpreis: ${invoice.order!.total.format()}',
                ),
              ),
            )),
        Spacer(flex: 15),
        Text(
          'Es erfolgt kein Ausweis der Umsatzsteuer aufgrund der Anwendung der Kleinunternehmerregelung gem. §19 UstG.',
          style: Theme.of(context).paragraphStyle.copyWith(
                fontSize: 8,
              ),
        ),
        Text(
          'Soweit nicht anders angegeben entspricht das Lieferdatum dem Rechnungsdatum.',
          style: Theme.of(context).paragraphStyle.copyWith(
                fontSize: 8,
              ),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
        Text('Vielen Dank für dein Vertrauen'),
        Spacer(flex: 5),
      ],
    ),
  ));

  return pdf;
}
