import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/models_extensions.dart';

class OrderListEntry extends StatelessWidget {
  final Invoices? invoice;
  final Orders order;
  final bool selected;
  final VoidCallback? onPressed;

  const OrderListEntry({
    super.key,
    required this.invoice,
    required this.order,
    this.selected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: ListTile.selectable(
        selected: selected,
        onPressed: onPressed,
        tileColor: WidgetStateProperty.resolveWith((states) {
          if (states.isHovered) {
            return FluentTheme.of(context).accentColor.withOpacity(0.1);
          }
          return FluentTheme.of(context)
              .resources
              .cardBackgroundFillColorDefault;
        }),
        leading: invoice == null
            ? Container(
                height: 40,
                width: 90,
                decoration: BoxDecoration(
                    color: FluentTheme.of(context).accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5)),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Draft')),
                ),
              )
            : Container(
                height: 40,
                width: 90,
                decoration: BoxDecoration(
                    color: FluentTheme.of(context).accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(invoice!.invoiceNumber)),
                ),
              ),
        title: Text(order.customerName),
        subtitle: Text(invoice == null
            ? order.date.formatDate()
            : invoice!.date.formatDate()),
        trailing: invoice == null
            ? Text(order.total.format())
            : Text(invoice!.amount.currency.format()),
      ),
    );
  }
}
