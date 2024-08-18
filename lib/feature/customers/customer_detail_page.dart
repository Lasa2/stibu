import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/feature/customers/customer_info_card.dart';
import 'package:stibu/feature/customers/customer_input.dart';
import 'package:stibu/main.dart';
import 'package:stibu/widgets/custom_page_header.dart';
import 'package:stibu_api/stibu_api.dart';

@RoutePage()
class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({
    super.key,
    @PathParam("customerId") required this.customerId,
  });

  final String customerId;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  Widget build(BuildContext context) {
    final customerFuture =
        getIt<CustomerRepository>().getCustomer(widget.customerId);

    return FutureBuilder(
        future: customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ProgressBar());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.isFailure) {
            return Center(child: Text('Error: ${snapshot.data!.failure}'));
          }
          final customer = snapshot.data!.success;

          return ScaffoldPage(
            header: CustomPageHeader(
              title: BreadcrumbBar(
                items: [
                  const BreadcrumbItem(label: Text("Customers"), value: 0),
                  BreadcrumbItem(label: Text(customer.name), value: 1)
                ],
                onItemPressed: (item) {
                  if (item.value == 0) {
                    context.router.maybePop();
                  }
                },
              ),
              commandBar: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: CommandBar(
                  mainAxisAlignment: MainAxisAlignment.end,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.edit),
                      label: const Text("Edit"),
                      onPressed: () async {
                        final updatedCustomer = await showDialog<Customer>(
                            context: context,
                            builder: (context) => CustomerInputDialog(
                                  title: 'Edit Customer',
                                  id: customer.id,
                                  name: customer.name,
                                  email: customer.email,
                                  phone: customer.phone,
                                  street: customer.street,
                                  zip: customer.zip,
                                  city: customer.city,
                                ));

                        if (updatedCustomer != null) {
                          final result = await getIt<CustomerRepository>()
                              .updateCustomer(updatedCustomer);

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
                                      content: Text("Customer updated"),
                                      severity: InfoBarSeverity.success,
                                    ));
                            setState(() {});
                          }
                        }
                      },
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.delete),
                      label: const Text("Delete"),
                      onPressed: () async {
                        final result = await getIt<CustomerRepository>()
                            .deleteCustomer(customer.id);

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
                          if (!context.mounted) return;
                          context.router.maybePop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            content: Column(
              children: [
                CustomerInfoCard(customer: customer),
                const Expanded(child: Placeholder()),
              ],
            ),
          );
        });
  }
}
