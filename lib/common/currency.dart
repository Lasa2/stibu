import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

class Currency implements Comparable<Currency> {
  final int _value;

  Currency(this._value);

  double get asDouble => _value / 100;
  int get asInt => _value;

  @override
  String toString() => asDouble.toString();
  String format({String symbol = '€'}) => NumberFormat.currency(
        locale: 'de_DE',
        symbol: symbol,
      ).format(asDouble);
  Currency.fromDouble(double value) : _value = (value * 100).toInt();
  Currency.fromString(String value)
      : _value = (double.parse(value) * 100).toInt();

  Currency operator +(Currency other) => Currency(_value + other._value);
  Currency operator -(Currency other) => Currency(_value - other._value);
  Currency operator *(int other) => Currency(_value * other);
  Currency operator -() => Currency(-_value);

  bool operator <(Currency other) => _value < other._value;
  bool operator <=(Currency other) => _value <= other._value;
  bool operator >(Currency other) => _value > other._value;
  bool operator >=(Currency other) => _value >= other._value;

  @override
  int compareTo(Object other) => switch (other) {
        Currency() => _value.compareTo(other._value),
        int() => _value.compareTo(other),
        double() => asDouble.compareTo(other),
        _ => throw ArgumentError('Cannot compare Currency with $other'),
      };
}

class CurrencyJsonConverter extends JsonConverter<Currency, int> {
  const CurrencyJsonConverter();

  @override
  Currency fromJson(int json) => Currency(json);

  @override
  int toJson(Currency object) => object._value;
}
