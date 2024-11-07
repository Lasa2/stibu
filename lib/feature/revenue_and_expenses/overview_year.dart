import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/feature/revenue_and_expenses/overview.dart';
import 'package:stibu/feature/router/router.gr.dart';

Map<int, ExpensesAndRevenueGroup> splitByMonth(ExpensesAndRevenueGroup group) {
  final Map<int, ExpensesAndRevenueGroup> result = {};

  for (final expense in group.expenses) {
    final month = expense.date.month;
    if (!result.containsKey(month)) {
      result[month] = ExpensesAndRevenueGroup(
        revenue: [],
        expenses: [],
      );
    }
    result[month]!.expenses.add(expense);
  }

  for (final invoice in group.revenue) {
    final month = invoice.date.month;
    if (!result.containsKey(month)) {
      result[month] = ExpensesAndRevenueGroup(
        revenue: [],
        expenses: [],
      );
    }
    result[month]!.revenue.add(invoice);
  }

  return result;
}

@RoutePage()
class OverviewYearPage extends StatelessWidget {
  OverviewYearPage({
    super.key,
    @PathParam('year') required this.year,
    required ExpensesAndRevenueGroup group,
  }) : groups = splitByMonth(group);

  final int year;
  final Map<int, ExpensesAndRevenueGroup> groups;

  @override
  Widget build(BuildContext context) {
    final months = groups.keys.toList()..sort();

    return ScaffoldPage(
      header: PageHeader(
        title: BreadcrumbBar<String>(
          items: [
            const BreadcrumbItem(
              label: Text('Overview'),
              value: RevenueAndExpenseOverviewRoute.name,
            ),
            BreadcrumbItem(
              label: Text(year.toString()),
              value: OverviewYearRoute.name,
            ),
          ],
          onItemPressed: (item) =>
              context.router.popUntilRouteWithName(item.value),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const ListTile(
              leading: Text('Month'),
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
                itemCount: groups.length,
                itemBuilder: (context, index) => OverviewYearListEntry(
                  onPressed: () async => context.navigateTo(
                    OverviewMonthRoute(
                      year: year,
                      month: months[index],
                      group: groups[months[index]]!,
                    ),
                  ),
                  month: months[index],
                  group: groups[months[index]]!,
                ),
              ),
            ),
            ListTile(
              leading: const Text('Cumulative'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    groups.values
                        .fold(
                          const Currency.zero(),
                          (previousValue, element) =>
                              previousValue + element.revenueTotal,
                        )
                        .format(),
                  ),
                  Text(
                    groups.values
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
                (groups.values.fold(
                          const Currency.zero(),
                          (previousValue, element) =>
                              previousValue + element.revenueTotal,
                        ) -
                        groups.values.fold(
                          const Currency.zero(),
                          (previousValue, element) =>
                              previousValue + element.expensesTotal,
                        ))
                    .format(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewYearListEntry extends StatelessWidget {
  final int month;
  final ExpensesAndRevenueGroup group;
  final VoidCallback? onPressed;

  const OverviewYearListEntry({
    super.key,
    required this.month,
    required this.group,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(2.5),
        child: ListTile.selectable(
          onPressed: onPressed,
          leading: Text(DateFormat.MMMM().format(DateTime(0, month))),
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
