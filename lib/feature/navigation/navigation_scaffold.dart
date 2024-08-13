import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:june/june.dart';
import 'package:stibu/feature/authentication/auth_state.dart';

final List<NavigationPaneItem> items = [
  PaneItem(
    icon: const Icon(FluentIcons.home),
    title: const Text('Dashboard'),
    body: const AutoRouter(),
  ),
  PaneItemSeparator(),
];

final List<NavigationPaneItem> footerItems = [
  PaneItem(
    icon: const Icon(FluentIcons.settings),
    title: const Text('Settings'),
    body: const AutoRouter(),
  ),
  PaneItemAction(
    icon: const Icon(FluentIcons.sign_out),
    title: const Text('Sign Out'),
    onTap: () async {
      final auth = June.getState(() => Auth());
      await auth.logout();
    },
  )
];

@RoutePage()
class NavigationScaffoldPage extends StatefulWidget {
  const NavigationScaffoldPage({
    super.key,
  });

  @override
  State<NavigationScaffoldPage> createState() => _NavigationScaffoldPageState();
}

class _NavigationScaffoldPageState extends State<NavigationScaffoldPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Stibu'),
      ),
      pane: NavigationPane(
        selected: selectedIndex,
        onChanged: (value) => setState(() => selectedIndex = value),
        displayMode: PaneDisplayMode.auto,
        items: items,
        footerItems: footerItems,
      ),
    );
  }
}
