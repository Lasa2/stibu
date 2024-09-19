import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/app_state/account.dart';
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

// ignore: constant_identifier_names
const CustomerTab = EmptyShellRoute('CustomerTab');

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        NoTransitionRoute(
          page: AuthenticationRoute.page,
        ),
        NoTransitionRoute(
          page: ProductKeyRoute.page,
          guards: [AuthGuard()],
        ),
        NoTransitionRoute(
          page: OnboardingRoute.page,
          guards: [AuthGuard()],
        ),
        NoTransitionRoute(
          path: "/",
          page: NavigationScaffoldRoute.page,
          guards: [AuthGuard(), OnboardingGuard(), ValidProductKeyGuard()],
          children: [
            NoTransitionRoute(
              path: "dashboard",
              page: DashboardRoute.page,
              initial: true,
            ),
            NoTransitionRoute(
              path: "customers",
              page: CustomerTab, children: [
              NoTransitionRoute(
                path: '',
                page: CustomerListRoute.page,
              ),
              NoTransitionRoute(
                path: ':id',
                page: CustomerDetailRoute.page,
              ),
            ]
            ),
            NoTransitionRoute(
              path: "invoices",
              page: InvoiceListRoute.page,
            ),
            NoTransitionRoute(
              page: ExpensesListRoute.page,
            ),
            NoTransitionRoute(
              page: OrderListRoute.page,
            ),
            NoTransitionRoute(
              page: CalendarRoute.page,
            ),
            NoTransitionRoute(
              path: "settings",
              page: SettingsRoute.page,
            ),
          ],
        ),
      ];
}

class ValidProductKeyGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final appwrite = getIt<AppwriteClient>();

    try {
      final user = await appwrite.account.get();
      final validProductKey = user.labels.contains("validProductKey");

      log.info('ValidProductKeyGuard: validProductKey=$validProductKey');
      if (validProductKey) {
        resolver.next(true);
      } else {
        resolver.redirect(ProductKeyRoute(
          onFinish: () {
            resolver.next(true);
          },
        ));
      }
    } on AppwriteException catch (e) {
      log.warning(e.message);
      resolver.next(false);
    }
  }
}

class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final appwrite = getIt<AppwriteClient>();

    try {
      final user = await appwrite.account.get();
      final onboardingCompleted =
          user.prefs.data['onboardingCompleted'] ?? false;

      log.info('OnboardingGuard: hasOnboarded=$onboardingCompleted');
      if (onboardingCompleted) {
        resolver.next(true);
      } else {
        resolver.redirect(OnboardingRoute(
          onFinish: () {
            resolver.next(true);
          },
        ));
      }
    } on AppwriteException catch (e) {
      log.warning(e.message);
      resolver.next(false);
    }
  }
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final auth = getIt<Authentication>();

    log.info("AuthGuard: isAuthenticated=${auth.isAuthenticated.value}");

    if (auth.isAuthenticated.value) {
      resolver.next(true);
    } else {
      late final StreamSubscription sub;
      sub = auth.isAuthenticated.listen((isAuthenticated) {
        if (isAuthenticated) {
          resolver.next(true);
          sub.cancel();
        }
      });

      resolver.redirect(AuthenticationRoute(
        onAuthenticated: () {
          resolver.next(true);
          sub.cancel();
        },
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
