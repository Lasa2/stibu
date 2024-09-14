import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/models_extensions.dart';
import 'package:stibu/common/show_result_info.dart';

class InputCouponDialog extends StatefulWidget {
  final String title;
  final String okText;
  final OrderCoupons? coupon;
  final void Function(OrderCoupons)? onDelete;

  const InputCouponDialog({
    super.key,
    required this.title,
    required this.okText,
    this.coupon,
    this.onDelete,
  });

  @override
  State<InputCouponDialog> createState() => _InputCouponDialogState();
}

class _InputCouponDialogState extends State<InputCouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _name = widget.coupon?.name;
  late int? _amount = widget.coupon?.amount;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormBox(
              initialValue: _name,
              placeholder: 'Name',
              onSaved: (newValue) => _name = newValue,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormBox(
              initialValue: _amount?.toString(),
              placeholder: 'Amount',
              onSaved: (newValue) => _amount = int.parse(newValue!),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.onDelete != null)
          Button(
            onPressed: () {
              widget.onDelete!(widget.coupon!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        Button(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (widget.coupon != null) {
                Navigator.of(context).pop(widget.coupon!.copyWith(
                  name: _name!,
                  amount: _amount!,
                ));
              } else {
                Navigator.of(context).pop(OrderCoupons(
                  name: _name!,
                  amount: _amount!,
                ));
              }
            }
          },
          child: Text(widget.okText),
        ),
      ],
    );
  }
}

Future<void> showAddCouponDialog(BuildContext context, Orders order) async =>
    await showDialog<OrderCoupons>(
      context: context,
      builder: (context) => const InputCouponDialog(
        title: 'Add Coupon',
        okText: 'Add',
      ),
    ).then((coupon) async => coupon != null
        ? await order.addCoupon(coupon).then(
              (value) async => await showResultInfo(context, value),
            )
        : null);

Future<void> showEditCouponDialog(
        BuildContext context, OrderCoupons coupon, Orders order) async =>
    await showDialog<OrderCoupons>(
      context: context,
      builder: (context) => InputCouponDialog(
        title: 'Edit Coupon',
        okText: 'Save',
        coupon: coupon,
        onDelete: (coupon) async =>
            await order.deleteCoupon(coupon).then(
                  (value) => showResultInfo(context, value),
                ),
      ),
    ).then((coupon) async {
      coupon != null
          ? await order.updateCoupon(coupon).then(
                (value) async => await showResultInfo(context, value),
              )
          : null;
    });
