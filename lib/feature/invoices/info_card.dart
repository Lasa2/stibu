import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/models_extensions.dart';

class InvoiceInfoCard extends StatelessWidget {
  final Invoices invoice;

  const InvoiceInfoCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.name,
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                  const Spacer(),
                  Text(invoice.notes ?? ''),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ID: ${invoice.invoiceNumber}'),
                  Text(invoice.date.formatDate()),
                  const Spacer(),
                  Text(invoice.amount.currency.format()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
