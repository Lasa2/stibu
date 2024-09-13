import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/feature/orders/add_product.dart';
import 'package:stibu/main.dart';

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
                  Text(order.invoice!.invoiceNumber,
                      style: FluentTheme.of(context).typography.bodyStrong),
                  Text(order.invoice!.date.formatDate(),
                      style: FluentTheme.of(context).typography.caption),
                ] else ...[
                  Container(
                    height: 40,
                    width: 90,
                    decoration: BoxDecoration(
                        color: FluentTheme.of(context)
                            .accentColor
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5)),
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

class OrderProductsList extends StatelessWidget {
  final Orders order;

  const OrderProductsList({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
              icon: const Icon(FluentIcons.save),
              label: const Text('Create invoice'),
              onPressed: () async => await order.createInvoice().then(
                    (value) => showResultInfo(context, value,
                        successMessage: 'Invoice created'),
                  ),
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
                        ? () => log.info('product: ${product.id}')
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
                        child: Text(product.title)),
                    subtitle: Text(
                        "${product.quantity} x ${product.price.currency.format()}"),
                    trailing: Row(
                      children: [
                        Text(product.total.format()),
                        if (order.invoice == null)
                          IconButton(
                            icon: const Icon(FluentIcons.delete),
                            onPressed: () async => await order
                                .copyWith(
                                    products: order.products!
                                        .where((element) =>
                                            element.id != product.id)
                                        .toList())
                                .update()
                                .then(
                                  (value) => showResultInfo(context, value),
                                ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      const Divider(),
      ListTile(
        title: const Text('Total'),
        trailing: Text(order.total.format()),
      ),
    ]);
  }
}
