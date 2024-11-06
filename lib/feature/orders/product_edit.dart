import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/show_result_info.dart';

class ProductEditDialog extends StatefulWidget {
  final OrderProducts product;
  final void Function(OrderProducts) onEdited;
  final void Function(OrderProducts) onDelete;

  const ProductEditDialog({
    super.key,
    required this.product,
    required this.onEdited,
    required this.onDelete,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _id = widget.product.id;
  late String _title = widget.product.title;
  late int _quantity = widget.product.quantity;
  late int _price = widget.product.price;

  @override
  Widget build(BuildContext context) => ContentDialog(
        title: const Text('Edit product'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'ID',
                child: TextFormBox(
                  initialValue: _id.toString(),
                  placeholder: 'ID',
                  onSaved: (newValue) => _id = int.parse(newValue!),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ID';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Name',
                child: TextFormBox(
                  initialValue: _title,
                  placeholder: 'Name',
                  onSaved: (newValue) => _title = newValue!,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Quantity',
                child: TextFormBox(
                  initialValue: _quantity.toString(),
                  placeholder: 'Quantity',
                  onSaved: (newValue) => _quantity = int.parse(newValue!),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Price',
                child: TextFormBox(
                  initialValue: _price.toString(),
                  placeholder: 'Price',
                  onSaved: (newValue) => _price = int.parse(newValue!),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Button(
            onPressed: () {
              widget.onDelete(widget.product);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
          Button(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onEdited(
                  widget.product.copyWith(
                    id: () => _id,
                    title: () => _title,
                    quantity: () => _quantity,
                    price: () => _price,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
}

Future<void> showProductEditDialog(
  BuildContext context,
  OrderProducts product,
  Orders order,
) async =>
    showDialog(
      context: context,
      builder: (context) => ProductEditDialog(
        product: product,
        onEdited: (product) async => order.updateProduct(product).then(
              (value) =>
                  context.mounted ? showResultInfo(context, value) : null,
            ),
        onDelete: (product) async => order.deleteProduct(product).then(
              (value) =>
                  context.mounted ? showResultInfo(context, value) : null,
            ),
      ),
    );
