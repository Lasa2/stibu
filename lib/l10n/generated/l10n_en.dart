import 'l10n.dart';

/// The translations for English (`en`).
class LangEn extends Lang {
  LangEn([String locale = 'en']) : super(locale);

  @override
  String get actionLogin => 'Login';

  @override
  String get appName => 'Stibu';

  @override
  String get constraintsRequired => 'This field is required';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get labelsEmail => 'Email';

  @override
  String get labelsLogin => 'Login';

  @override
  String get labelsPassword => 'Password';
}
