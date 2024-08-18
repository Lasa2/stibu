// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:fluent_ui/fluent_ui.dart' as _i9;
import 'package:stibu/feature/authentication/create_account_page.dart' as _i1;
import 'package:stibu/feature/authentication/login_page.dart' as _i5;
import 'package:stibu/feature/customers/customer_detail_page.dart' as _i2;
import 'package:stibu/feature/customers/customer_list_page.dart' as _i3;
import 'package:stibu/feature/dashboard/dashboad_page.dart' as _i4;
import 'package:stibu/feature/navigation/navigation_scaffold.dart' as _i6;
import 'package:stibu/feature/settings/settings_page.dart' as _i7;

/// generated route for
/// [_i1.CreateAccountPage]
class CreateAccountRoute extends _i8.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i8.PageRouteInfo>? children})
      : super(
          CreateAccountRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateAccountRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.CreateAccountPage();
    },
  );
}

/// generated route for
/// [_i2.CustomerDetailPage]
class CustomerDetailRoute extends _i8.PageRouteInfo<CustomerDetailRouteArgs> {
  CustomerDetailRoute({
    _i9.Key? key,
    required String customerId,
    List<_i8.PageRouteInfo>? children,
  }) : super(
          CustomerDetailRoute.name,
          args: CustomerDetailRouteArgs(
            key: key,
            customerId: customerId,
          ),
          rawPathParams: {'customerId': customerId},
          initialChildren: children,
        );

  static const String name = 'CustomerDetailRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CustomerDetailRouteArgs>(
          orElse: () => CustomerDetailRouteArgs(
              customerId: pathParams.getString('customerId')));
      return _i2.CustomerDetailPage(
        key: args.key,
        customerId: args.customerId,
      );
    },
  );
}

class CustomerDetailRouteArgs {
  const CustomerDetailRouteArgs({
    this.key,
    required this.customerId,
  });

  final _i9.Key? key;

  final String customerId;

  @override
  String toString() {
    return 'CustomerDetailRouteArgs{key: $key, customerId: $customerId}';
  }
}

/// generated route for
/// [_i3.CustomerListPage]
class CustomerListRoute extends _i8.PageRouteInfo<void> {
  const CustomerListRoute({List<_i8.PageRouteInfo>? children})
      : super(
          CustomerListRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomerListRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.CustomerListPage();
    },
  );
}

/// generated route for
/// [_i4.DashboardPage]
class DashboardRoute extends _i8.PageRouteInfo<void> {
  const DashboardRoute({List<_i8.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.DashboardPage();
    },
  );
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i8.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i9.Key? key,
    void Function(bool)? onResult,
    List<_i8.PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<LoginRouteArgs>(orElse: () => const LoginRouteArgs());
      return _i5.LoginPage(
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

  final _i9.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i6.NavigationScaffoldPage]
class NavigationScaffoldRoute extends _i8.PageRouteInfo<void> {
  const NavigationScaffoldRoute({List<_i8.PageRouteInfo>? children})
      : super(
          NavigationScaffoldRoute.name,
          initialChildren: children,
        );

  static const String name = 'NavigationScaffoldRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.NavigationScaffoldPage();
    },
  );
}

/// generated route for
/// [_i7.SettingsPage]
class SettingsRoute extends _i8.PageRouteInfo<void> {
  const SettingsRoute({List<_i8.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingsPage();
    },
  );
}
