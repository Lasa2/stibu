import 'package:fluent_ui/fluent_ui.dart';

bool isLargeScreen(BuildContext context) =>
    MediaQuery.of(context).size.width > 960;
