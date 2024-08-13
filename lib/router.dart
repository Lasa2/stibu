import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:june/june.dart';
import 'package:stibu/feature/authentication/auth_state.dart';
import 'package:stibu/main.dart';
import 'package:stibu/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: "/login", page: LoginRoute.page),
        AutoRoute(path: "/sign-up", page: CreateAccountRoute.page),
        AutoRoute(
          path: "/",
          page: NavigationScaffoldRoute.page,
          guards: [AuthGuard()],
          children: [
            AutoRoute(
              path: "dashboard",
              page: DashboardRoute.page,
            ),
            AutoRoute(path: "customers", page: CustomersListRoute.page),
            AutoRoute(path: "settings", page: SettingsRoute.page),
          ],
        ),
      ];
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final auth = June.getState(() => Auth());

    log.info('Auth guard: ${auth.isAuthenticated}');

    if (auth.isAuthenticated) {
      resolver.next(true);
    } else {
      resolver.redirect(LoginRoute(
        onResult: resolver.next,
      ));
    }
  }
}

class RouteLogger extends AutoRouteObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    log.info('Pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log.info('Popped: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    log.info(
        'Replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}
