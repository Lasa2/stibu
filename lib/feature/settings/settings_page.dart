import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Expanded(
        child: Center(
      child: Placeholder(child: Text("Settings Body")),
    ));
  }
}
