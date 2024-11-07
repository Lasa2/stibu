import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;
import 'package:stibu/common/currency.dart';

String getDecimalSeparator(String locale) =>
    numberFormatSymbols[locale]?.DECIMAL_SEP ?? '.';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int _fractionDigits;

  DecimalTextInputFormatter({int fractionDigits = 2})
      : assert(fractionDigits >= 0, "fractionDigits can't be negative"),
        _fractionDigits = fractionDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;

    String newText = newValue.text;

    // TODO: handle separator for different locales
    newText = newText.replaceAll(',', '.');
    newText = newText.replaceAll(RegExp(r'[^0-9.]'), '');

    // limit the to only one . as separator
    if (newText.contains('.') &&
        newText.indexOf('.') != newText.lastIndexOf('.')) {
      newText = oldValue.text;
    }

    // insert 0 if text starts with .
    if (newText.contains('.') && newText.indexOf('.') == 0) {
      newText = '0$newText';
      newSelection = newSelection.copyWith(
        baseOffset: newSelection.baseOffset + 1,
        extentOffset: newSelection.extentOffset + 1,
      );
    }

    // limit fraction digits
    if (newText.contains('.') &&
        newText.substring(newText.indexOf('.') + 1).length > _fractionDigits) {
      newText =
          newText.substring(0, newText.indexOf('.') + _fractionDigits + 1);
    }

    // if newSelection is longer than newText, we have to adjust it
    if (newSelection.end > newText.length) {
      newSelection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }

    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

class CurrencyInput extends StatelessWidget {
  const CurrencyInput({
    super.key,
    this.amount,
    this.onSaved,
    this.validator,
    this.textInputAction,
  });

  final Currency? amount;
  final void Function(Currency?)? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextFormBox(
        initialValue: amount?.toString(),
        placeholder: 'Amount',
        suffix: const Text('€'),
        inputFormatters: [
          DecimalTextInputFormatter(),
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSaved: (newValue) => newValue != null
            ? onSaved?.call(Currency.fromString(newValue))
            : onSaved?.call(null),
        validator: validator,
        textInputAction: textInputAction,
      );
}
