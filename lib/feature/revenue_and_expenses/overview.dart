import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/feature/app_state/realtime_subscriptions.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

class ExpensesAndRevenueGroup {
  ExpensesAndRevenueGroup({
    required this.revenue,
    required this.expenses,
  });
  final List<Invoices> revenue;
  final List<Expenses> expenses;

  Currency get revenueTotal => revenue.fold(
        const Currency.zero(),
        (previousValue, element) => previousValue + element.amount.currency,
      );

  Currency get expensesTotal => expenses.fold(
        const Currency.zero(),
        (previousValue, element) => previousValue + element.amount.currency,
      );

  Currency get total => revenueTotal - expensesTotal;
}

@RoutePage()
class RevenueAndExpenseOverviewPage extends StatefulWidget {
  const RevenueAndExpenseOverviewPage({super.key});

  @override
  State<RevenueAndExpenseOverviewPage> createState() =>
      _RevenueAndExpenseOverviewPageState();
}

class _RevenueAndExpenseOverviewPageState
    extends State<RevenueAndExpenseOverviewPage> {
  final Map<int, ExpensesAndRevenueGroup> _groups = {};
  bool _loading = true;
  StreamSubscription? _expensesSubscription;
  StreamSubscription? _invoicesSubscription;

  Future<void> _loadData() async {
    // load all expenses and invoces in a year

    final List<Expenses> expenses = [];

    await Expenses.page(offset: 0, limit: 100).then((result) async {
      final (total, newExpenses) = result.success;
      expenses.addAll(newExpenses);

      while (newExpenses.length < total) {
        final last = newExpenses.last;
        await Expenses.page(last: last, limit: 100).then((result) {
          final (total, newExpenses) = result.success;
          expenses.addAll(newExpenses);
        });
      }
    });

    final List<Invoices> invoices = [];

    await Invoices.page(offset: 0, limit: 100).then((result) async {
      final (total, newInvoices) = result.success;
      invoices.addAll(newInvoices);

      while (newInvoices.length < total) {
        final last = newInvoices.last;
        await Invoices.page(last: last, limit: 100).then((result) {
          final (total, newInvoices) = result.success;
          invoices.addAll(newInvoices);
        });
      }
    });

    for (final expense in expenses) {
      final year = expense.date.year;
      if (!_groups.containsKey(year)) {
        _groups[year] = ExpensesAndRevenueGroup(revenue: [], expenses: []);
      }
      setState(() {
        _groups[year]!.expenses.add(expense);
      });
    }

    for (final invoice in invoices) {
      final year = invoice.date.year;
      if (!_groups.containsKey(year)) {
        _groups[year] = ExpensesAndRevenueGroup(revenue: [], expenses: []);
      }
      setState(() {
        _groups[year]!.revenue.add(invoice);
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
    _expensesSubscription =
        getIt<RealtimeSubscriptions>().expensesUpdates.listen((update) {
      switch (update.type) {
        case RealtimeUpdateType.create:
          setState(() {
            final year = update.item.date.year;
            if (!_groups.containsKey(year)) {
              _groups[year] =
                  ExpensesAndRevenueGroup(revenue: [], expenses: []);
            }
            setState(() {
              _groups[year]!.expenses.add(update.item);
            });
          });
        case RealtimeUpdateType.update:
          setState(() {
            final year = update.item.date.year;
            final index = _groups[year]?.expenses.indexWhere(
                  (e) => e.$id == update.item.$id,
                );
            if (index != null && index != -1) {
              _groups[year]!.expenses[index] = update.item;
            }
          });
        case RealtimeUpdateType.delete:
          setState(() {
            final year = update.item.date.year;
            final index = _groups[year]?.expenses.indexWhere(
                  (e) => e.$id == update.item.$id,
                );
            if (index != null && index != -1) {
              _groups[year]!.expenses.removeAt(index);
            }
          });
      }

      _invoicesSubscription =
          getIt<RealtimeSubscriptions>().invoicesUpdates.listen((update) {
        switch (update.type) {
          case RealtimeUpdateType.create:
            setState(() {
              final year = update.item.date.year;
              if (!_groups.containsKey(year)) {
                _groups[year] =
                    ExpensesAndRevenueGroup(revenue: [], expenses: []);
              }
              setState(() {
                _groups[year]!.revenue.add(update.item);
              });
            });
          case RealtimeUpdateType.update:
            setState(() {
              final year = update.item.date.year;
              final index = _groups[year]?.revenue.indexWhere(
                    (e) => e.$id == update.item.$id,
                  );
              if (index != null && index != -1) {
                _groups[year]!.revenue[index] = update.item;
              }
            });
          case RealtimeUpdateType.delete:
            setState(() {
              final year = update.item.date.year;
              final index = _groups[year]?.revenue.indexWhere(
                    (e) => e.$id == update.item.$id,
                  );
              if (index != null && index != -1) {
                _groups[year]!.revenue.removeAt(index);
              }
            });
        }
      });
    });
  }

  @override
  Future<void> dispose() async {
    await _expensesSubscription?.cancel();
    await _invoicesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = _groups.keys.toList()..sort();

    return ScaffoldPage(
      header: const PageHeader(
        title: BreadcrumbBar(
          items: [
            BreadcrumbItem(label: Text('Overview'), value: 0),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const ListTile(
              leading: Text('Year'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Revenue'),
                  Text('Expenses'),
                ],
              ),
              trailing: Text('Total'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) => OverviewListEntry(
                  onPressed: () async => context.navigateTo(
                    OverviewYearRoute(
                      year: years[index],
                      group: _groups[years[index]]!,
                    ),
                  ),
                  year: years[index],
                  group: _groups[years[index]]!,
                ),
              ),
            ),
            if (_loading) const Center(child: ProgressBar()),
            ListTile(
              leading: const Text('Cumulative'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _groups.values
                        .fold(
                          const Currency.zero(),
                          (previousValue, element) =>
                              previousValue + element.revenueTotal,
                        )
                        .format(),
                  ),
                  Text(
                    _groups.values
                        .fold(
                          const Currency.zero(),
                          (previousValue, element) =>
                              previousValue + element.expensesTotal,
                        )
                        .format(),
                  ),
                ],
              ),
              trailing: Text(
                _groups.values
                    .fold(
                      const Currency.zero(),
                      (previousValue, element) => previousValue + element.total,
                    )
                    .format(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewListEntry extends StatelessWidget {
  const OverviewListEntry({
    super.key,
    required this.onPressed,
    required this.year,
    required this.group,
  });

  final VoidCallback onPressed;
  final int year;
  final ExpensesAndRevenueGroup group;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(2.5),
        child: ListTile.selectable(
          onPressed: onPressed,
          leading: Text(year.toString()),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(group.revenueTotal.format()),
              Text(
                (-group.expensesTotal).format(),
                style: FluentTheme.of(context).typography.body?.copyWith(
                      color: FluentTheme.of(context)
                          .resources
                          .systemFillColorCritical,
                    ),
              ),
            ],
          ),
          trailing: Text(group.total.format()),
        ),
      );
}
