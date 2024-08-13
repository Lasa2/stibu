import 'l10n.dart';

/// The translations for German (`de`).
class LangDe extends Lang {
  LangDe([String locale = 'de']) : super(locale);

  @override
  String get actionLogin => 'Einloggen';

  @override
  String get appName => 'Stibu';

  @override
  String get constraintsRequired => 'Dieses Feld ist erforderlich';

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get labelsEmail => 'Email';

  @override
  String get labelsLogin => 'Einloggen';

  @override
  String get labelsPassword => 'Passwort';
}
