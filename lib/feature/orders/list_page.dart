import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/is_large_screen.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/feature/app_state/app_state.dart';
import 'package:stibu/feature/orders/create_order.dart';
import 'package:stibu/feature/orders/list_detail.dart';
import 'package:stibu/feature/orders/list_entry.dart';
import 'package:stibu/main.dart';

@RoutePage()
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  int? selectedIndex;
  Orders? selectOrder;

  final _orders = <Orders>[];
  int _totalOders = 0;
  StreamSubscription? _subscription;

  Future<void> _loadOrders() async {
    late final (int, List<Orders>) result;
    if (_orders.isEmpty) {
      result = (await Orders.page(offset: 0)).success;
    } else {
      result = (await Orders.page(last: _orders.last)).success;
    }
    setState(() {
      _totalOders = result.$1;
      _orders.addAll(result.$2);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _subscription = getIt<AppState>().ordersUpdates.listen((event) {
      switch (event.type) {
        case RealtimeUpdateType.create:
          setState(() {
            _orders.add(event.item);
          });
          break;
        case RealtimeUpdateType.update:
          final index = _orders.indexWhere((e) => e.$id == event.item.$id);
          if (index != -1) {
            setState(() {
              _orders[index] = event.item;
            });
          }
          break;
        case RealtimeUpdateType.delete:
          _orders.removeWhere((e) => e.$id == event.item.$id);
          break;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final largeScreen = isLargeScreen(context);
    selectedIndex = largeScreen ? selectedIndex : null;

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Orders'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New'),
              onPressed: () async {
                final customers = <Customers>[];
                // final customers = await Customers.all();

                // if (customers.isFailure && context.mounted) {
                //   await showResultInfo(context, customers);
                //   return;
                // }

                if (!context.mounted) return;
                return showDialog<Orders>(
                  context: context,
                  builder: (context) => CreateOrder(
                    customers: customers,
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      selectOrder = value;
                    });
                  }
                });
              },
            ),
            if (selectedIndex != null && _orders[selectedIndex!].canDelete) ...[
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () {
                  final index = selectedIndex;
                  setState(() {
                    selectedIndex = null;
                  });

                  _orders[index!].delete().then((value) {
                    showResultInfo(context, value).then((_) {
                      if (value.isFailure) {
                        setState(() {
                          selectedIndex = index;
                        });
                      }
                    });
                  });
                },
              ),
            ],
          ],
        ),
      ),
      content: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _totalOders > _orders.length
                  ? _orders.length + 1
                  : _orders.length,
              itemBuilder: (context, index) {
                if (index >= _orders.length) {
                  _loadOrders();
                  return const Center(child: ProgressBar());
                }

                final order = _orders[index];
                final invoice = order.invoice;

                return OrderListEntry(
                  invoice: invoice,
                  order: order,
                  selected: selectedIndex == index,
                  onPressed: () {
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
              child: Column(
                children: [
                  OrderInfoCard(order: _orders[selectedIndex!]),
                  Expanded(
                    child: OrderProductsList(
                      order: _orders[selectedIndex!],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
