// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:fluent_ui/fluent_ui.dart' as _i8;
import 'package:stibu/feature/authentication/create_account_page.dart' as _i1;
import 'package:stibu/feature/authentication/login_page.dart' as _i4;
import 'package:stibu/feature/customers/customers_list_page.dart' as _i2;
import 'package:stibu/feature/dashboard/dashboad_page.dart' as _i3;
import 'package:stibu/feature/navigation/navigation_scaffold.dart' as _i5;
import 'package:stibu/feature/settings/settings_page.dart' as _i6;

/// generated route for
/// [_i1.CreateAccountPage]
class CreateAccountRoute extends _i7.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i7.PageRouteInfo>? children})
      : super(
          CreateAccountRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateAccountRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.CreateAccountPage();
    },
  );
}

/// generated route for
/// [_i2.CustomersListPage]
class CustomersListRoute extends _i7.PageRouteInfo<void> {
  const CustomersListRoute({List<_i7.PageRouteInfo>? children})
      : super(
          CustomersListRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomersListRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.CustomersListPage();
    },
  );
}

/// generated route for
/// [_i3.DashboardPage]
class DashboardRoute extends _i7.PageRouteInfo<void> {
  const DashboardRoute({List<_i7.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.DashboardPage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i7.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i8.Key? key,
    void Function(bool)? onResult,
    List<_i7.PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<LoginRouteArgs>(orElse: () => const LoginRouteArgs());
      return _i4.LoginPage(
        key: args.key,
        onResult: args.onResult,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({
    this.key,
    this.onResult,
  });

  final _i8.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i5.NavigationScaffoldPage]
class NavigationScaffoldRoute extends _i7.PageRouteInfo<void> {
  const NavigationScaffoldRoute({List<_i7.PageRouteInfo>? children})
      : super(
          NavigationScaffoldRoute.name,
          initialChildren: children,
        );

  static const String name = 'NavigationScaffoldRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i5.NavigationScaffoldPage();
    },
  );
}

/// generated route for
/// [_i6.SettingsPage]
class SettingsRoute extends _i7.PageRouteInfo<void> {
  const SettingsRoute({List<_i7.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingsPage();
    },
  );
}
