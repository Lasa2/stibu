import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  /// Formats the [DateTime] as a date [String].
  /// For example, 'January 1, 2021'.
  String formatDate() => DateFormat.yMMMMd().format(this);

  /// Formats the [DateTime] as a time [String].
  /// For example, '12:00 AM'.
  String formatTime() => DateFormat.jm().format(this);

  /// Formats the [DateTime] as a date and time [String].
  /// For example, 'January 1, 2021 12:00 AM'.
  String formatDateTime() => DateFormat.yMMMMd().add_jm().format(this);

  /// Formats the [DateTime] as a month [String].
  /// For example, 'January'.
  String formatMonth() => DateFormat.yMMMM().format(this);

  /// Formats the [DateTime] as a abbreviated day [String].
  /// For example, 'Mon'.
  String formatDayShort() => DateFormat.E().format(this);

  /// Returns the [DateTime] with the day set based on the [weekday] parameter.
  /// For example, if [weekday] is 1, it will return the [DateTime] for Monday.
  /// If the [weekday] is 7, it will return the [DateTime] for Sunday.
  static DateTime weekDay(int weekday) => DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - weekday),
      );
}

enum Cuttoff { minute, second, millisecond, microsecond }

extension DateTimeStipTime on DateTime {
  /// Returns a new [DateTime] with the time set to 00:00:00.000.
  DateTime stripTime() =>
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  DateTime stripDate({Cuttoff cuttoff = Cuttoff.minute}) => isUtc
      ? DateTime.utc(0, 0, 0, hour, minute, second, millisecond, microsecond)
      : DateTime(
          0,
          0,
          0,
          hour,
          minute,
          cuttoff == Cuttoff.minute ? 0 : second,
          cuttoff == Cuttoff.second ? 0 : millisecond,
          0,
        );

  DateTime mergeTime(DateTime time) => isUtc
      ? DateTime.utc(
          year,
          month,
          day,
          time.hour,
          time.minute,
          time.second,
          time.millisecond,
          time.microsecond,
        )
      : DateTime(
          year,
          month,
          day,
          time.hour,
          time.minute,
          time.second,
          time.millisecond,
          time.microsecond,
        );
}
