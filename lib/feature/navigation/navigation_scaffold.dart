import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:june/june.dart';
import 'package:stibu/feature/authentication/auth_state.dart';
import 'package:stibu/router.gr.dart';

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
  final autoRouterKey = GlobalKey<AutoRouterState>();
  late final autoRouter = AutoRouter(
    key: autoRouterKey,
  );
  late final items = [
    PaneItem(
        icon: const Icon(FluentIcons.home),
        title: const Text('Dashboard'),
        body: autoRouter),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.people),
      title: const Text('Customers'),
      body: autoRouter,
    ),
  ];
  late final footerItems = [
    PaneItem(
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: autoRouter,
    ),
    PaneItemAction(
      icon: const Icon(FluentIcons.sign_out),
      title: const Text('Sign Out'),
      onTap: () async {
        final auth = June.getState(() => Auth());
        await auth.logout();
      },
    ),
  ];

  late final navigationRoutes = {
    items[0]: const DashboardRoute(),
    items[2]: const CustomersListRoute(),
    footerItems[0]: const SettingsRoute(),
  };

  List<PaneItem> get allNavigationItems =>
      (items + footerItems).whereType<PaneItem>().toList();

  void onChanged(BuildContext context, int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    context.router.push(navigationRoutes[allNavigationItems[index]]!);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: defaultTargetPlatform == TargetPlatform.windows
            ? MoveWindow(
                child: SizedBox.expand(
                  child: Container(
                    color: Colors.transparent,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Stibu'),
                    ),
                  ),
                ),
              )
            : const Text('Stibu'),
        actions: defaultTargetPlatform == TargetPlatform.windows
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              )
            : null,
        leading: AutoLeadingButton(
          builder: (context, leadingType, onPressed) {
            return Builder(
                builder: (context) => PaneItem(
                      icon: const Icon(FluentIcons.back, size: 14.0),
                      title: const Text("Back"),
                      body: const SizedBox.shrink(),
                      enabled: leadingType != LeadingType.noLeading,
                    ).build(
                      context,
                      false,
                      onPressed,
                      displayMode: PaneDisplayMode.compact,
                    ));
          },
        ),
      ),
      pane: NavigationPane(
        selected: selectedIndex,
        onChanged: (index) => onChanged(context, index),
        displayMode: PaneDisplayMode.auto,
        items: items,
        footerItems: footerItems,
      ),
    );
  }
}
