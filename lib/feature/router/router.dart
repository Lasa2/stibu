import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:stibu/feature/authentication/repository.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

class NoTransitionRoute extends CustomRoute {
  NoTransitionRoute({
    required super.page,
    super.fullscreenDialog,
    super.maintainState,
    super.fullMatch,
    super.guards,
    super.usesPathAsKey,
    super.children,
    super.meta,
    super.title,
    super.path,
    super.keepHistory,
    super.initial,
    super.allowSnapshotting,
    // Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder,
    super.customRouteBuilder,
    // int? durationInMilliseconds,
    // int? reverseDurationInMilliseconds,
    super.opaque = true,
    super.barrierDismissible = true,
    super.barrierLabel,
    super.restorationId,
    super.barrierColor,
  }) : super(
          transitionsBuilder: TransitionsBuilders.noTransition,
          durationInMilliseconds: 0,
          reverseDurationInMilliseconds: 0,
        );
}

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: "/login", page: LoginRoute.page),
        AutoRoute(path: "/sign-up", page: CreateAccountRoute.page),
        NoTransitionRoute(
          path: "/",
          page: NavigationScaffoldRoute.page,
          guards: [AuthGuard()],
          children: [
            NoTransitionRoute(
              path: "dashboard",
              page: DashboardRoute.page,
              initial: true,
            ),
            NoTransitionRoute(
              path: "customers",
              page: CustomerListRoute.page,
            ),
            NoTransitionRoute(
              path: "customers/:customerId",
              page: CustomerDetailRoute.page,
            ),
            NoTransitionRoute(
              path: "settings",
              page: SettingsRoute.page,
            ),
          ],
        ),
      ];
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final auth = await getIt.getAsync<AuthState>();

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
