import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/feature/customers/customer_info_card.dart';
import 'package:stibu/feature/customers/customer_input.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';
import 'package:stibu_api/stibu_api.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960;
}

Future<Customer?> _showCustomerCreateDialog(BuildContext context) async {
  final newId = await getIt<CustomerRepository>().newID();
  if (!context.mounted) return null;

  if (newId.isFailure) {
    await displayInfoBar(context,
        builder: (context, close) => InfoBar(
              title: const Text("Error"),
              content: Text(newId.failure),
              severity: InfoBarSeverity.error,
            ));
    return null;
  }

  final customer = await showDialog<Customer>(
      context: context,
      builder: (context) => CustomerInputDialog(
            id: newId.success,
            title: "Create Customer",
          ));

  if (customer != null) {
    final result = await getIt<CustomerRepository>().createCustomer(customer);
    if (!context.mounted) return null;

    if (result.isFailure) {
      await displayInfoBar(context,
          builder: (context, close) => InfoBar(
                title: const Text("Error"),
                content: Text(result.failure),
                severity: InfoBarSeverity.error,
              ));
    } else {
      await displayInfoBar(context,
          builder: (context, close) => const InfoBar(
                title: Text("Success"),
                content: Text("Customer created"),
                severity: InfoBarSeverity.success,
              ));
      return customer;
    }
  }
  return null;
}

Future<Customer?> _showCustomerEditDialog(
    BuildContext context, CustomerAppwrite customer) async {
  final updatedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => CustomerInputDialog(
            title: "Edit Customer",
            id: customer.id,
            name: customer.name,
            email: customer.email,
            phone: customer.phone,
            street: customer.street,
            zip: customer.zip,
            city: customer.city,
          ));

  if (updatedCustomer != null) {
    final result =
        await getIt<CustomerRepository>()
        .updateCustomer(customer.copyFromCustomer(updatedCustomer));
    if (!context.mounted) return null;

    if (result.isFailure) {
      await displayInfoBar(context,
          builder: (context, close) => InfoBar(
                title: const Text("Error"),
                content: Text(result.failure),
                severity: InfoBarSeverity.error,
              ));
    } else {
      await displayInfoBar(context,
          builder: (context, close) => const InfoBar(
                title: Text("Success"),
                content: Text("Customer updated"),
                severity: InfoBarSeverity.success,
              ));
      return updatedCustomer;
    }
  }
  return null;
}

@RoutePage()
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  int? selectedIndex;
  Customer? selectCustomer;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);
    selectedIndex = isLargeScreen ? selectedIndex : null;

    return StreamBuilder(
      stream: getIt<CustomerRepository>().customers,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final customers = snapshot.data as List<CustomerAppwrite>;

          if (selectCustomer != null) {
            final index = customers.indexWhere((element) =>
                element.id == selectCustomer!.id &&
                element.name == selectCustomer!.name);
            if (index != -1) {
              selectedIndex = index;
              selectCustomer = null;
            }
          }

          if (customers.isEmpty) {
            return ScaffoldPage(
              header: PageHeader(
                title: const BreadcrumbBar(items: [
                  BreadcrumbItem(label: Text("Customers"), value: 0)
                ]),
                commandBar: CommandBar(
                    mainAxisAlignment: MainAxisAlignment.end,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.add),
                        label: const Text('New'),
                        onPressed: () => _showCustomerCreateDialog(context),
                      )
                    ]),
              ),
              content: const Center(
                child: Text('No customers found'),
              ),
            );
          } else {
            return ScaffoldPage(
              header: PageHeader(
                title: const BreadcrumbBar(items: [
                  BreadcrumbItem(label: Text("Customers"), value: 0),
                ]),
                commandBar: CommandBar(
                    mainAxisAlignment: MainAxisAlignment.end,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.add),
                        label: const Text('New'),
                        onPressed: () async {
                          final result =
                              await _showCustomerCreateDialog(context);
                          if (result != null) {
                            setState(() {
                              selectCustomer = result;
                            });
                          }
                        },
                      ),
                      if (isLargeScreen && selectedIndex != null) ...[
                        CommandBarButton(
                          icon: const Icon(FluentIcons.edit),
                          label: const Text('Edit'),
                          onPressed: () async {
                            final result = await _showCustomerEditDialog(
                                context, customers[selectedIndex!]);
                            if (result != null) {
                              setState(() {
                                selectCustomer = result;
                              });
                            }
                          },
                        ),
                        CommandBarButton(
                          icon: const Icon(FluentIcons.delete),
                          label: const Text('Delete'),
                          onPressed: () async {
                            final result = await getIt<CustomerRepository>()
                                .deleteCustomer(customers[selectedIndex!].$id);
                            if (!context.mounted) return;

                            if (result.isFailure) {
                              await displayInfoBar(context,
                                  builder: (context, close) => InfoBar(
                                        title: const Text("Error"),
                                        content: Text(result.failure),
                                        severity: InfoBarSeverity.error,
                                      ));
                            } else {
                              await displayInfoBar(context,
                                  builder: (context, close) => const InfoBar(
                                        title: Text("Success"),
                                        content: Text("Customer deleted"),
                                        severity: InfoBarSeverity.success,
                                      ));
                              setState(() {
                                selectedIndex = null;
                              });
                            }
                          },
                        ),
                      ]
                    ]),
              ),
              content: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return CustomerListEntry(
                            customerId: customer.id,
                            customerName: customer.name,
                            customerAddress: customer.address,
                            isSelected: selectedIndex == index,
                            onPressed: () {
                              if (!isLargeScreen) {
                                AutoRouter.of(context).push(CustomerDetailRoute(
                                    id: customer.$id));
                                return;
                              }
                              if (selectedIndex == index) return;
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (isLargeScreen && selectedIndex != null)
                      Expanded(
                        child: CustomerListDetail(
                          customer: customers[selectedIndex!],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        } else {
          return ScaffoldPage(
            header: PageHeader(
              title: const BreadcrumbBar(
                  items: [BreadcrumbItem(label: Text("Customers"), value: 0)]),
              commandBar: CommandBar(
                  mainAxisAlignment: MainAxisAlignment.end,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.add),
                      label: const Text('New'),
                      onPressed: () => _showCustomerCreateDialog(context),
                    )
                  ]),
            ),
            content: snapshot.connectionState == ConnectionState.done
                ? const Center(child: ProgressBar())
                : Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
          );
        }
      },
    );
  }
}

class CustomerListDetail extends StatelessWidget {
  final Customer customer;

  const CustomerListDetail({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomerInfoCard(customer: customer),
        const Expanded(child: Placeholder()),
      ],
    );
  }
}

class CustomerListEntry extends StatelessWidget {
  final int customerId;
  final String customerName;
  final String customerAddress;
  final VoidCallback? onPressed;
  final bool isSelected;

  const CustomerListEntry({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: ListTile.selectable(
        selected: isSelected,
        tileColor: WidgetStateProperty.resolveWith((states) {
          if (states.isHovered) {
            return FluentTheme.of(context).accentColor.withOpacity(0.1);
          }
          return FluentTheme.of(context)
              .resources
              .cardBackgroundFillColorDefault;
        }),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Center(
            child: Text(customerId.toString()),
          ),
        ),
        title: Text(customerName),
        subtitle: Text(customerAddress),
        onPressed: onPressed,
        trailing: IconButton(
          icon: const Icon(FluentIcons.chevron_right),
          onPressed: null,
          focusable: false,
          iconButtonMode: IconButtonMode.large,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(
                FluentTheme.of(context).resources.textFillColorPrimary),
          ),
        ),
      ),
    );
  }
}
