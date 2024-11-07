import 'package:auto_route/auto_route.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show DataCell, Material;
import 'package:intl/intl.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/feature/revenue_and_expenses/overview.dart';
import 'package:stibu/feature/router/router.gr.dart';

@RoutePage()
class OverviewMonthPage extends StatelessWidget {
  const OverviewMonthPage({
    super.key,
    @PathParam('year') required this.year,
    @PathParam('month') required this.month,
    required this.group,
  });

  final int year;
  final int month;
  final ExpensesAndRevenueGroup group;

  @override
  Widget build(BuildContext context) {
    final invoices = group.revenue
      ..sort((a, b) => a.invoiceNumber.compareTo(b.invoiceNumber));
    final expenses = group.expenses
      ..sort((a, b) => a.expenseNumber.compareTo(b.expenseNumber));

    final rows = <DataRow2>[
      for (var i = 0; i < invoices.length || i < expenses.length; i++)
        DataRow2(
          cells: [
            DataCell(
              Text(i < invoices.length ? invoices[i].invoiceNumber : ''),
            ),
            DataCell(Text(i < invoices.length ? invoices[i].name : '')),
            DataCell(
              Text(
                i < invoices.length ? invoices[i].amount.currency.format() : '',
              ),
            ),
            DataCell(
              Text(i < expenses.length ? expenses[i].expenseNumber : ''),
            ),
            DataCell(Text(i < expenses.length ? expenses[i].name : '')),
            DataCell(
              Text(
                i < expenses.length ? expenses[i].amount.currency.format() : '',
              ),
            ),
          ],
        ),
    ];

    final revenueTotal = invoices.fold(
      const Currency.zero(),
      (previousValue, element) => previousValue + element.amount.currency,
    );

    final expensesTotal = expenses.fold(
      const Currency.zero(),
      (previousValue, element) => previousValue + element.amount.currency,
    );

    final total = revenueTotal - expensesTotal;

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
            BreadcrumbItem(
              label: Text(DateFormat.MMMM().format(DateTime(0, month))),
              value: OverviewMonthRoute.name,
            ),
          ],
          onItemPressed: (item) {
            context.router.popUntilRouteWithName(item.value);
          },
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Material(
                child: DataTable2(
                  columnSpacing: 8,
                  dividerThickness: 0.5,
                  columns: const [
                    DataColumn2(
                      label: Text('Invoice Number'),
                      numeric: true,
                      size: ColumnSize.S,
                    ),
                    DataColumn2(label: Text('Name'), size: ColumnSize.L),
                    DataColumn2(
                      label: Text('Value'),
                      numeric: true,
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text('Expense Number'),
                      numeric: true,
                      size: ColumnSize.S,
                    ),
                    DataColumn2(label: Text('Name'), size: ColumnSize.L),
                    DataColumn2(
                      label: Text('Value'),
                      numeric: true,
                      size: ColumnSize.S,
                    ),
                  ],
                  rows: rows,
                ),
              ),
            ),
            ListTile(
              leading: const Text('Total'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Revenue: ${revenueTotal.format()}'),
                  Text('Expenses: ${(-expensesTotal).format()}'),
                ],
              ),
              trailing: Text('Total: ${total.format()}'),
            ),
          ],
        ),
      ),
    );
  }
}
