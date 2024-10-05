import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/new_ids.dart';

class InvoiceInputDialog extends StatefulWidget {
  final String title;
  final Invoices? invoice;

  const InvoiceInputDialog({
    super.key,
    required this.title,
    this.invoice,
  });

  @override
  State<InvoiceInputDialog> createState() => _InvoiceInputDialogState();
}

class _InvoiceInputDialogState extends State<InvoiceInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date = widget.invoice?.date.toLocal() ?? DateTime.now();
  late String? _name = widget.invoice?.name;
  late String? _notes = widget.invoice?.notes;
  late int? _amount = widget.invoice?.amount;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.title),
      actions: [
        Button(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState!.save();

              late final Invoices invoice;
              if (widget.invoice != null) {
                invoice = widget.invoice!.copyWith(
                  date: _date.toUtc(),
                  name: _name,
                  notes: _notes,
                  amount: _amount,
                );
              } else {
                final invoiceNumber = await newInvoiceNumber(
                  _date.toUtc(),
                );

                if (!context.mounted) return;
                if (invoiceNumber.isFailure) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) => InfoBar(
                      title: const Text("Error"),
                      content: Text(invoiceNumber.failure),
                      severity: InfoBarSeverity.error,
                    ),
                  );
                  return;
                }
                invoice = Invoices(
                  invoiceNumber: invoiceNumber.success,
                  date: _date.toUtc(),
                  name: _name!,
                  notes: _notes,
                  amount: _amount!,
                );
              }

              if (!context.mounted) return;
              Navigator.of(context).pop(invoice);
            }
          },
          child: const Text('Save'),
        ),
        Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
      content: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          children: [
            InfoLabel(
              label: "Date",
              child: DatePicker(
                selected: _date,
                onChanged: (value) => _date = value,
              ),
            ),
            InfoLabel(
              label: "Name",
              child: TextFormBox(
                initialValue: _name,
                placeholder: "Title",
                onSaved: (value) => _name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            InfoLabel(
              label: "Description",
              child: TextFormBox(
                initialValue: _notes,
                placeholder: "Description",
                onSaved: (value) =>
                    value?.isEmpty ?? true ? _notes = null : _notes = value,
              ),
            ),
            InfoLabel(
              label: "Amount",
              child: NumberFormBox(
                initialValue: _amount?.toString(),
                placeholder: "Amount",
                showCursor: false,
                clearButton: false,
                mode: SpinButtonPlacementMode.none,
                onChanged: (_) {}, // required to show as enabled
                onSaved: (value) => _amount = double.parse(value!).toInt(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
