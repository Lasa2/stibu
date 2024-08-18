import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/feature/customers/model.dart';

class CustomerInputDialog extends StatefulWidget {
  final String title;
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? street;
  final int? zip;
  final String? city;

  const CustomerInputDialog({
    super.key,
    required this.title,
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.street,
    this.zip,
    this.city,
  });

  @override
  State<CustomerInputDialog> createState() => _CustomerInputDialogState();
}

class _CustomerInputDialogState extends State<CustomerInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final String _id = widget.id;
  late String? _name = widget.name;
  late String? _email = widget.email;
  late String? _phone = widget.phone;
  late String? _street = widget.street;
  late int? _zip = widget.zip;
  late String? _city = widget.city;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.title),
      actions: [
        Button(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();

              final customer = Customer(
                id: _id,
                name: _name!,
                email: _email?.isNotEmpty == true ? _email : null,
                phone: _phone?.isNotEmpty == true ? _phone : null,
                street: _street?.isNotEmpty == true ? _street : null,
                zip: _zip,
                city: _city?.isNotEmpty == true ? _city : null,
              );

              Navigator.of(context).pop(customer);
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
                label: 'Customer ID',
                child: TextFormBox(
                  initialValue: _id,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'ID',
                  readOnly: true,
                ),
              ),
              InfoLabel(
                label: 'Name',
                child: TextFormBox(
                  initialValue: _name,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'Name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
              ),
              InfoLabel(
                label: 'Email',
                child: TextFormBox(
                  initialValue: _email,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value,
                ),
              ),
              InfoLabel(
                label: 'Phone',
                child: TextFormBox(
                  initialValue: _phone,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'Phone',
                  onChanged: (value) => _phone = value,
                ),
              ),
              InfoLabel(
                label: 'Street',
                child: TextFormBox(
                  initialValue: _street,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'Street',
                  onSaved: (value) => _street = value,
                ),
              ),
              InfoLabel(
                label: 'ZIP',
                child: NumberFormBox(
                    value: _zip,
                    placeholder: 'ZIP',
                    showCursor: false,
                    clearButton: false,
                    mode: SpinButtonPlacementMode.none,
                    onChanged: (value) {},
                    onSaved: (value) => _zip = int.tryParse(value ?? '')),
              ),
              InfoLabel(
                label: 'City',
                child: TextFormBox(
                  initialValue: _city,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  placeholder: 'City',
                  onSaved: (value) => _city = value,
                ),
              ),
            ]),
      ),
    );
  }
}
