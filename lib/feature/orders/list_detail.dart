import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/feature/orders/coupon_input.dart';
import 'package:stibu/feature/orders/product_add.dart';
import 'package:stibu/feature/orders/product_edit.dart';

class OrderInfoCard extends StatelessWidget {
  final Orders order;

  const OrderInfoCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  order.customerName,
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
                Text(order.street ?? ''),
                Text("${order.zip} ${order.city}"),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (order.invoice != null) ...[
                  Text(
                    order.invoice!.invoiceNumber,
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  Text(
                    order.invoice!.date.formatDate(),
                    style: FluentTheme.of(context).typography.caption,
                  ),
                ] else ...[
                  Container(
                    height: 40,
                    width: 90,
                    decoration: BoxDecoration(
                      color:
                          FluentTheme.of(context).accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text('Draft')),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> createInvoice(BuildContext context, Orders order) async =>
    await showDialog(
      context: context,
      builder: (context) => CreateOrderInvoiceDialog(
        order: order,
      ),
    );

class CreateOrderInvoiceDialog extends StatefulWidget {
  final Orders order;

  const CreateOrderInvoiceDialog({
    super.key,
    required this.order,
  });

  @override
  State<CreateOrderInvoiceDialog> createState() =>
      _CreateOrderInvoiceDialogState();
}

class _CreateOrderInvoiceDialogState extends State<CreateOrderInvoiceDialog> {
  DateTime selected = DateTime.now();
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Center(child: Text('Create invoice')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InfoLabel(
                label: 'Date',
                child: DatePicker(
                  selected: selected,
                  onChanged: (value) {
                    setState(() {
                      selected = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 295),
                child: InfoLabel(
                  label: 'Note',
                  child: TextBox(
                    controller: controller,
                    placeholder: 'Note',
                    maxLines: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Button(
          onPressed: () async => widget.order
              .createInvoice(
            date: selected,
            note: controller.text,
          )
              .then((result) {
            if (result.isSuccess) {
              Navigator.of(context).pop();
            } else {
              showResultInfo(context, result);
            }
          }),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class OrderProductsList extends StatelessWidget {
  final Orders order;

  const OrderProductsList({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (order.invoice == null)
          CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Add product'),
                onPressed: () async =>
                    await showAddProductsDialog(context, order),
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Add coupon'),
                onPressed: () async =>
                    await showAddCouponDialog(context, order),
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.save),
                label: const Text('Create invoice'),
                onPressed: () async => await createInvoice(context, order),
              ),
            ],
          ),
        Expanded(
          child: order.products?.isEmpty ?? true
              ? const Center(child: Text('No products added'))
              : ListView.builder(
                  itemCount: order.products!.length,
                  itemBuilder: (context, index) {
                    final product = order.products![index];

                    return ListTile(
                      onPressed: order.invoice == null
                          ? () async => await showProductEditDialog(
                              context, product, order)
                          : null,
                      leading: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: FluentTheme.of(context)
                              .accentColor
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(product.id.toString()),
                          ),
                        ),
                      ),
                      title: Tooltip(
                        message: product.title,
                        displayHorizontally: false,
                        useMousePosition: false,
                        style: TooltipThemeData(
                          textStyle: FluentTheme.of(context).typography.body,
                          preferBelow: true,
                          // waitDuration: Duration.zero,
                        ),
                        child: Text(product.title),
                      ),
                      subtitle: Text(
                        "${product.quantity} x ${product.price.currency.format()}",
                      ),
                      trailing: Text(product.total.format()),
                    );
                  },
                ),
        ),
        if (order.coupons?.isNotEmpty ?? false) ...[
          const Divider(),
          for (final coupon in order.coupons!)
            ListTile(
              title: Text(coupon.name),
              trailing: Text(coupon.amount.currency.format()),
              onPressed: order.invoice == null
                  ? () async =>
                      await showEditCouponDialog(context, coupon, order)
                  : null,
            ),
        ],
        const Divider(),
        ListTile(
          title: const Text('Total'),
          trailing: Text(order.total.format()),
        ),
      ],
    );
  }
}
