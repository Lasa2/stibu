import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/is_large_screen.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/new_ids.dart';
import 'package:stibu/feature/app_state/realtime_subscriptions.dart';
import 'package:stibu/feature/invoices/info_card.dart';
import 'package:stibu/feature/invoices/input.dart';
import 'package:stibu/main.dart';

Future<Invoices?> _showInvoiceCreateDialog(BuildContext context) async {
  final invoice = await showDialog<Invoices>(
      context: context,
      builder: (context) => const InvoiceInputDialog(
            title: 'Create Invoice',
          ));

  if (invoice != null) {
    final newInvoiceId = await newInvoiceNumber(invoice.date);
    if (newInvoiceId.isFailure && context.mounted) {
      await displayInfoBar(context,
          builder: (context, close) => InfoBar(
                title: const Text("Error"),
                content: Text(newInvoiceId.failure),
                severity: InfoBarSeverity.error,
              ));
      return null;
    }
    final user = await getIt<AppwriteClient>().account.get();
    final result = await invoice
        .copyWith(invoiceNumber: newInvoiceId.success, $permissions: [
      Permission.read(Role.user(user.$id)),
      Permission.update(Role.user(user.$id)),
    ]).create();

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
                content: Text("Invoice created"),
                severity: InfoBarSeverity.success,
              ));
      return invoice;
    }
  }
  return null;
}

Future<Invoices?> _showInvoiceEditDialog(
    BuildContext context, Invoices invoice) async {
  final updatedInvoice = await showDialog<Invoices>(
      context: context,
      builder: (context) => InvoiceInputDialog(
            title: 'Edit Invoice',
            invoice: invoice,
          ));

  if (updatedInvoice != null) {
    final result = await updatedInvoice.update();

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
      return updatedInvoice;
    }
  }
  return null;
}

@RoutePage()
class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  int? selectedIndex;
  Invoices? selectInvoice;
  final _invoices = <Invoices>[];
  int _totalInvoices = 0;
  StreamSubscription? _subscription;

  Future<void> _loadInvoices() async {
    late final (int, List<Invoices>) result;
    if (_invoices.isEmpty) {
      result = (await Invoices.page(offset: 0)).success;
    } else {
      result = (await Invoices.page(last: _invoices.last)).success;
    }
    setState(() {
      _totalInvoices = result.$1;
      _invoices.addAll(result.$2);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _subscription =
        getIt<RealtimeSubscriptions>().invoicesUpdates.listen((invoices) {
      switch (invoices.type) {
        case RealtimeUpdateType.create:
          setState(() {
            _totalInvoices += 1;
            _invoices.add(invoices.item);
          });
          break;
        case RealtimeUpdateType.update:
          final index = _invoices.indexWhere((e) => e.$id == invoices.item.$id);
          if (index != -1) {
            setState(() {
              _invoices[index] = invoices.item;
            });
          }
          break;
        case RealtimeUpdateType.delete:
          final index = _invoices.indexWhere((e) => e.$id == invoices.item.$id);
          if (index != -1) {
            setState(() {
              _totalInvoices -= 1;
              _invoices.removeAt(index);
            });
          }
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

    // If there is a selected invoice, show the detail view
    final selectIndex =
        _invoices.indexWhere((e) => e.$id == selectInvoice?.$id);
    selectedIndex = selectIndex != -1 ? selectIndex : selectedIndex;

    // validate the selected index
    if (selectedIndex != null && selectedIndex! >= _invoices.length) {
      selectedIndex = null;
    }

    return ScaffoldPage(
        header: PageHeader(
          title: const Text("Invoices"),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('New'),
                onPressed: () async {
                  final result = await _showInvoiceCreateDialog(context);
                  if (result != null) {
                    setState(() {
                      selectInvoice = result;
                    });
                  }
                },
              ),
              if (largeScreen &&
                  selectedIndex != null &&
                  _invoices[selectedIndex!].canUpdate) ...[
                CommandBarButton(
                  icon: const Icon(FluentIcons.edit),
                  label: const Text('Edit'),
                  onPressed: () async {
                    final result = await _showInvoiceEditDialog(
                        context, _invoices[selectedIndex!]);
                    if (result != null) {
                      setState(() {
                        selectInvoice = result;
                      });
                    }
                  },
                ),
                // CommandBarButton(
                //   icon: const Icon(FluentIcons.delete),
                //   label: const Text('Delete'),
                //   onPressed: () async {
                //     final result = await _invoices[selectedIndex!].delete();

                //     if (!context.mounted) return;

                //     if (result.isFailure) {
                //       await displayInfoBar(context,
                //           builder: (context, close) => InfoBar(
                //                 title: const Text("Error"),
                //                 content: Text(result.failure),
                //                 severity: InfoBarSeverity.error,
                //               ));
                //     } else {
                //       await displayInfoBar(context,
                //           builder: (context, close) => const InfoBar(
                //                 title: Text("Success"),
                //                 content: Text("Receipt deleted"),
                //                 severity: InfoBarSeverity.success,
                //               ));
                //       setState(() {
                //         selectedIndex = null;
                //       });
                //     }
                //   },
                // ),
              ]
            ],
          ),
        ),
        content: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _totalInvoices > _invoices.length
                    ? _invoices.length + 1
                    : _invoices.length,
                itemBuilder: (context, index) {
                  if (index >= _invoices.length) {
                    _loadInvoices();
                    return const Center(child: ProgressBar());
                  }

                  final invoice = _invoices[index];
                  return InvoiceListEntry(
                    invoice: invoice,
                    selected: selectedIndex == index,
                    onPressed: () {
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
                child: InvoiceListDetail(invoice: _invoices[selectedIndex!]),
              ),
          ],
        ));
  }
}

class InvoiceListEntry extends StatelessWidget {
  final Invoices invoice;
  final bool selected;
  final VoidCallback? onPressed;

  const InvoiceListEntry({
    super.key,
    required this.invoice,
    this.selected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: ListTile.selectable(
        selected: selected,
        onPressed: onPressed,
        tileColor: WidgetStateProperty.resolveWith((states) {
          if (states.isHovered) {
            return FluentTheme.of(context).accentColor.withOpacity(0.1);
          }
          return FluentTheme.of(context)
              .resources
              .cardBackgroundFillColorDefault;
        }),
        leading: Container(
          height: 40,
          decoration: BoxDecoration(
              color: FluentTheme.of(context).accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(invoice.invoiceNumber)),
          ),
        ),
        title: Text(invoice.name),
        subtitle: Text(invoice.date.formatDate()),
        trailing: Text(invoice.amount.currency.format()),
      ),
    );
  }
}

class InvoiceListDetail extends StatelessWidget {
  final Invoices invoice;

  const InvoiceListDetail({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InvoiceInfoCard(
          invoice: invoice,
        ),
        const Expanded(child: Placeholder()),
      ],
    );
  }
}
