import 'package:appwrite/models.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/api/accounts.dart';
import 'package:stibu/api/avatars.dart';
import 'package:stibu/feature/navigation/windows_appbar.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

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
  final List<RouteDestination>? items;

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
    this.items,
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
  const RouteDestination(
    title: "Orders",
    icon: FluentIcons.invoice,
    route: OrderListRoute(),
  ),
  const RouteDestination(
    title: 'Invoices',
    icon: FluentIcons.invoice,
    route: InvoiceListRoute(),
  ),
  const RouteDestination(
    title: 'Expenses',
    icon: FluentIcons.money,
    route: ExpensesListRoute(),
  ),
  const RouteDestination(
    title: 'Calendar',
    icon: FluentIcons.calendar,
    route: CalendarRoute(),
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

List<RouteDestination> flatten(List<Object> items) {
  return items.whereType<RouteDestination>().expand((element) {
    if (element.items != null) {
      return [element, ...element.items!];
    }
    return [element];
  }).toList();
}

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

  List<RouteDestination> get routeDestinations =>
      (flatten(items) + flatten(footerItems)).toList(growable: false);

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
        if (element.items == null) {
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
        } else {
          return PaneItemExpander(
            icon: Icon(element.icon),
            title: Text(element.title),
            body: autoRouter,
            items: buildItems(element.items!, selectedIndex),
            onTap: () => onTap(context, element, selectedIndex),
            trailing: element.trailing ?? PaneItemExpander.kDefaultTrailing,
            infoBadge: element.infoBadge,
            mouseCursor: element.mouseCursor,
            tileColor: element.tileColor,
            selectedTileColor: element.selectedTileColor,
          );
        }
      } else if (element is NavigationPaneItem) {
        return element;
      }
      throw Exception('Invalid item type');
    }).toList();
  }

  User? user;
  Image? avatar;

  @override
  void initState() {
    super.initState();
    getIt<AccountsRepository>().sessionStream.listen((session) async {
      if (session != null) {
        final user = await getIt<AccountsRepository>().user;
        if (user.isSuccess) {
          final avatar = await getIt<AvatarsRepository>().getAvatar(
            name: user.success.name,
            width: 32,
            height: 32,
          );
          if (avatar.isSuccess) {
            setState(() {
              this.user = user.success;
              this.avatar = avatar.success;
            });
          }
        }
      } else {
        setState(() {
          user = null;
          avatar = null;
        });
      }
    });
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
        header: SizedBox(
          height: 78,
          child: ListTile(
            leading: avatar,
            title: Text(user?.name ?? "User"),
            subtitle: Text(user?.email ?? ""),
          ),
        ),
        items: buildItems(items, selectedIndex),
        footerItems: buildItems(footerItems, selectedIndex),
      ),
    );
  }
}
