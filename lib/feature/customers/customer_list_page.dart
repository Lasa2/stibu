import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/is_large_screen.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/new_ids.dart';
import 'package:stibu/common/scroll_to_index.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/feature/app_state/realtime_subscriptions.dart';
import 'package:stibu/feature/customers/customer_info_card.dart';
import 'package:stibu/feature/customers/customer_input.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

Future<Customers?> _showCustomerCreateDialog(BuildContext context) async =>
    newCustomerId().then((result) {
      if (!context.mounted) return null;
      showResultInfo(context, result);

      return showDialog<Customers>(
        context: context,
        builder: (context) => CustomerInputDialog(
          id: result.success,
          title: 'Create Customer',
        ),
      ).then((customer) async {
        if (customer != null) {
          final user = await getIt<AppwriteClient>().account.get();
          return customer
              .copyWith(
                $permissions: [
                  Permission.read(Role.user(user.$id)),
                  Permission.update(Role.user(user.$id)),
                ],
              )
              .create()
              .then((result) {
                if (!context.mounted) return null;
                showResultInfo(
                  context,
                  result,
                  successMessage: 'Customer created',
                );
                return result.isSuccess ? customer : null;
              });
        }
        return null;
      });
    });

Future<Customers?> _showCustomerEditDialog(
  BuildContext context,
  Customers customer,
) async {
  final updatedCustomer = await showDialog<Customers>(
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
      customer: customer,
    ),
  );

  if (updatedCustomer != null) {
    return updatedCustomer.update().then((result) {
      if (!context.mounted) return null;
      showResultInfo(context, result, successMessage: 'Customer updated');
      return result.isSuccess ? updatedCustomer : null;
    });
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
  Customers? selectCustomer;
  final _customers = <Customers>[];
  int _totalcustomers = 0;
  StreamSubscription? _subscription;
  final _scrollController = ScrollController();

  Future<void> _loadCustomers() async {
    // TODO: cleanup
    late final (int, List<Customers>) result;
    if (_customers.isEmpty) {
      result = (await Customers.page(offset: 0)).success;
    } else {
      result = (await Customers.page(last: _customers.last)).success;
    }
    setState(() {
      _totalcustomers = result.$1;
      _customers.addAll(result.$2);
    });
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadCustomers());
    _subscription =
        getIt<RealtimeSubscriptions>().customerUpdates.listen((event) {
      switch (event.type) {
        case RealtimeUpdateType.create:
          setState(() {
            _totalcustomers += 1;
            _customers.add(event.item);
          });
        case RealtimeUpdateType.update:
          final index = _customers.indexWhere((e) => e.id == event.item.id);
          if (index != -1) {
            setState(() {
              _customers[index] = event.item;
            });
          }
        case RealtimeUpdateType.delete:
          final index = _customers.indexWhere((e) => e.id == event.item.id);
          if (index != -1) {
            setState(() {
              _totalcustomers -= 1;
              _customers.removeAt(index);
            });
          }
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final largeScreen = isLargeScreen(context);
    selectedIndex = largeScreen ? selectedIndex : null;

    if (selectCustomer != null) {
      final index = _customers.indexWhere((e) => e.id == selectCustomer!.id);
      if (index != -1) {
        selectedIndex = index;
        selectCustomer = null;
      }
    }

    if (selectedIndex != null && selectedIndex! >= _customers.length) {
      selectedIndex = null;
    }

    if (selectedIndex != null) {
      unawaited(scrollToIndex(selectedIndex!, controller: _scrollController));
    }

    return ScaffoldPage(
      header: PageHeader(
        title: const BreadcrumbBar(
          items: [
            BreadcrumbItem(label: Text('Customers'), value: 0),
          ],
        ),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New'),
              onPressed: () async {
                final result = await _showCustomerCreateDialog(context);
                if (result != null) {
                  setState(() {
                    selectCustomer = result;
                  });
                }
              },
            ),
            if (largeScreen && selectedIndex != null) ...[
              CommandBarButton(
                icon: const Icon(FluentIcons.edit),
                label: const Text('Edit'),
                onPressed: () async =>
                    _showCustomerEditDialog(context, _customers[selectedIndex!])
                        .then(
                  (result) => setState(() {
                    selectCustomer = result;
                  }),
                ),
              ),
              // CommandBarButton(
              //   icon: const Icon(FluentIcons.delete),
              //   label: const Text('Anonymize'),
              //   onPressed: () =>
              //       _customers[selectedIndex!].anonymize().then((result) {
              //     showResultInfo(context, result,
              //         successMessage: "Customer anonymized");
              //     if (result.isSuccess) {
              //       setState(() {
              //         selectedIndex = null;
              //       });
              //     }
              //   }),
              // ),
            ],
          ],
        ),
      ),
      content: Row(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemExtent: 58,
              itemCount: _totalcustomers > _customers.length
                  ? _customers.length + 1
                  : _customers.length,
              itemBuilder: (context, index) {
                if (index >= _customers.length) {
                  unawaited(_loadCustomers());
                  return const Center(child: ProgressBar());
                }

                final customer = _customers[index];
                return CustomerListEntry(
                  customerId: customer.id,
                  customerName: customer.name,
                  customerAddress: customer.address,
                  isSelected: selectedIndex == index,
                  onPressed: () async {
                    if (!largeScreen) {
                      await context
                          .navigateTo(CustomerDetailRoute(id: customer.$id));
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
          if (largeScreen && selectedIndex != null)
            Expanded(
              child: CustomerListDetail(
                customer: _customers[selectedIndex!],
              ),
            ),
        ],
      ),
    );
  }
}

class CustomerListDetail extends StatelessWidget {
  final Customers customer;

  const CustomerListDetail({super.key, required this.customer});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          CustomerInfoCard(customer: customer),
          const Expanded(child: Placeholder()),
        ],
      );
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
  Widget build(BuildContext context) => Padding(
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
                FluentTheme.of(context).resources.textFillColorPrimary,
              ),
            ),
          ),
        ),
      );
}
