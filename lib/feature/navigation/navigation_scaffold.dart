import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/feature/navigation/windows_appbar.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';
import 'package:stibu_api/stibu_api.dart';

class RouteDestination {
  final String title;
  final IconData icon;
  final PageRouteInfo route;
  final Widget? trailing;
  final Widget? infoBadge;
  final MouseCursor? mouseCursor;
  final WidgetStateColor? tileColor;
  final WidgetStateColor? selectedTileColor;
  final bool enabled;

  const RouteDestination({
    required this.title,
    required this.icon,
    required this.route,
    this.trailing,
    this.infoBadge,
    this.mouseCursor,
    this.tileColor,
    this.selectedTileColor,
    this.enabled = true,
  });
}

var items = <Object>[
  const RouteDestination(
    title: 'Dashboard',
    icon: FluentIcons.home,
    route: DashboardRoute(),
  ),
  PaneItemSeparator(),
  const RouteDestination(
    title: 'Customers',
    icon: FluentIcons.people,
    route: CustomerListRoute(),
  ),
];

var footerItems = <Object>[
  const RouteDestination(
    title: 'Settings',
    icon: FluentIcons.settings,
    route: SettingsRoute(),
  ),
  PaneItemAction(
    icon: const Icon(FluentIcons.sign_out),
    title: const Text('Sign Out'),
    onTap: () => getIt<AccountsRepository>().logout(),
  ),
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
  final autoRouterKey = GlobalKey<AutoRouterState>();
  late final autoRouter = AutoRouter(
    key: autoRouterKey,
  );

  List<RouteDestination> get routeDestinations => (items + footerItems)
      .whereType<RouteDestination>()
      .toList(growable: false);

  void onChanged(BuildContext context, int index) {
    context.router.push(routeDestinations[index].route);
    setState(() {});
  }

  void onTap(
      BuildContext context, RouteDestination element, int selectedIndex) {
    final index = routeDestinations.indexOf(element);
    final isSameIndex = selectedIndex == index;
    final childRouter = context.router.childControllers.last;

    if (isSameIndex && childRouter.current.name != element.route.routeName) {
      childRouter.maybePop();
    } else if (!isSameIndex) {
      onChanged(context, index);
    }
  }

  List<NavigationPaneItem> buildItems(List<Object> items, int selectedIndex) {
    return items.map<NavigationPaneItem>((element) {
      if (element is RouteDestination) {
        return PaneItem(
          icon: Icon(element.icon),
          title: Text(element.title),
          body: autoRouter,
          onTap: () => onTap(context, element, selectedIndex),
          trailing: element.trailing,
          infoBadge: element.infoBadge,
          mouseCursor: element.mouseCursor,
          tileColor: element.tileColor,
          selectedTileColor: element.selectedTileColor,
          enabled: element.enabled,
        );
      } else if (element is NavigationPaneItem) {
        return element;
      }
      throw Exception('Invalid item type');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: selected index not always correct
    final topRouteName = context
        .router.childControllers.firstOrNull?.currentSegments.firstOrNull?.name;
    final index = routeDestinations.indexWhere(
      (element) => element.route.routeName == topRouteName,
    );
    final selectedIndex = index == -1 ? 0 : index;

    return NavigationView(
      appBar: buildNavigationAppBar(context),
      pane: NavigationPane(
        selected: selectedIndex,
        // onChanged: (index) => onChanged(context, index),
        displayMode: PaneDisplayMode.auto,
        header: const SizedBox(
          height: 78,
          child: ListTile(
            leading: Icon(FluentIcons.contact),
            title: Text('User Name'),
            subtitle: Text("Some Text"),
          ),
        ),
        items: buildItems(items, selectedIndex),
        footerItems: buildItems(footerItems, selectedIndex),
      ),
    );
  }
}
