import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/show_result_info.dart';

class CreateOrder extends StatefulWidget {
  final List<Customers> customers;

  const CreateOrder({super.key, required this.customers});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  Customers? _customer;
  DateTime _orderDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Create Order'),
      content: Column(
        children: [
          if (_customer != null)
            ListTile(
              title: Text(_customer!.name),
              subtitle: Text(_customer!.address),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DatePicker(
              selected: _orderDate,
              onChanged: (date) => setState(() {
                _orderDate = date;
              }),
            ),
          ),
          Divider(
            style: DividerThemeData(
                decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FluentTheme.of(context).inactiveColor,
                  width: 0.5,
                ),
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: AutoSuggestBox<Customers>(
              trailingIcon: const Icon(FluentIcons.search),
              placeholder: 'Search for a customer',
              items: widget.customers
                  .map((customer) => AutoSuggestBoxItem<Customers>(
                        label: customer.name,
                        value: customer,
                      ))
                  .toList(),
              onSelected: (item) => setState(() {
                _customer = item.value;
              }),
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.customers.length,
              itemBuilder: (context, index) {
                final customer = widget.customers[index];

                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.address),
                  onPressed: () => setState(() {
                    _customer = customer;
                  }),
                );
              })
        ],
      ),
      actions: [
        Button(
          onPressed: () async {
            if (_customer != null) {
              final order = Orders(
                date: _orderDate,
                customerId: _customer!.id,
                customerName: _customer!.name,
                street: _customer!.street,
                zip: _customer!.zip,
                city: _customer!.city,
                invoice: null,
              );

              order.create().then((value) {
                showResultInfo(context, value).then((_) {
                  if (value.isSuccess) {
                    Navigator.of(context).pop(order);
                  }
                });
              });
            }
          },
          child: const Text('Create'),
        ),
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
