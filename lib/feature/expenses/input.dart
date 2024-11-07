import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/common/new_ids.dart';
import 'package:stibu/widgets/currency_input.dart';

class ExpenseInputDialog extends StatefulWidget {
  final String title;
  final Expenses? expense;

  const ExpenseInputDialog({
    super.key,
    required this.title,
    this.expense,
  });

  @override
  State<ExpenseInputDialog> createState() => _ExpenseInputDialogState();
}

class _ExpenseInputDialogState extends State<ExpenseInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date = widget.expense?.date.toLocal() ?? DateTime.now();
  late String? _name = widget.expense?.name;
  late String? _notes = widget.expense?.notes;
  late int? _amount = widget.expense?.amount;

  @override
  Widget build(BuildContext context) => ContentDialog(
        title: Text(widget.title),
        actions: [
          Button(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState!.save();

                late final Expenses expense;
                if (widget.expense != null) {
                  expense = widget.expense!.copyWith(
                    date: () => _date.toUtc(),
                    name: () => _name!,
                    notes: () => _notes,
                    amount: () => _amount!,
                  );
                } else {
                  final expenseNumber = await newExpenseNumber(_date.toUtc());

                  if (!context.mounted) return;
                  if (expenseNumber.isFailure) {
                    await displayInfoBar(
                      context,
                      builder: (context, close) => InfoBar(
                        title: const Text('Error'),
                        content: Text(expenseNumber.failure),
                        severity: InfoBarSeverity.error,
                      ),
                    );
                    return;
                  }
                  expense = Expenses(
                    expenseNumber: expenseNumber.success,
                    date: _date.toUtc(),
                    name: _name!,
                    notes: _notes,
                    amount: _amount!,
                  );
                }

                if (!context.mounted) return;
                Navigator.of(context).pop(expense);
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
                label: 'Date',
                child: DatePicker(
                  selected: _date,
                  onChanged: (value) => _date = value,
                ),
              ),
              InfoLabel(
                label: 'Name',
                child: TextFormBox(
                  initialValue: _name,
                  placeholder: 'Title',
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
                label: 'Description',
                child: TextFormBox(
                  initialValue: _notes,
                  placeholder: 'Description',
                  onSaved: (value) =>
                      value?.isEmpty ?? true ? _notes = null : _notes = value,
                ),
              ),
              InfoLabel(
                label: 'Amount',
                child: CurrencyInput(
                  amount: _amount != null ? Currency(_amount!) : null,
                  onSaved: (value) => _amount = value?.asInt,
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
