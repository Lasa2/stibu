import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

final _lightThemeColors = WindowButtonColors(
  normal: Colors.transparent,
  iconNormal: const Color(0xFF000000),
  mouseOver: const Color(0xFFE9E9E9),
  iconMouseOver: const Color(0xFF000000),
  mouseDown: const Color(0xFFEDEDED),
  iconMouseDown: const Color(0xFF000000),
);

final _darkThemeColors = WindowButtonColors(
  normal: Colors.transparent,
  iconNormal: const Color(0xFFFFFFFF),
  mouseOver: const Color(0xFF2D2D2D),
  iconMouseOver: const Color(0xFFFFFFFF),
  mouseDown: const Color(0xFF292929),
  iconMouseDown: const Color(0xFFFFFFFF),
);

final _closeLightThemeColors = WindowButtonColors(
  normal: Colors.transparent,
  iconNormal: const Color(0xFF000000),
  mouseOver: const Color(0xFFC42B1C),
  iconMouseOver: const Color(0xFFF8E4E3),
  mouseDown: const Color(0xFFC73C31),
  iconMouseDown: const Color(0xFFE8AEAA),
);

final _closeDarkThemeColors = WindowButtonColors(
  normal: Colors.transparent,
  iconNormal: const Color(0xFFF8E4E3),
  mouseOver: const Color(0xFFC42B1C),
  iconMouseOver: const Color(0xFFF8E4E3),
  mouseDown: const Color(0xFFB3271B),
  iconMouseDown: const Color(0xFFE5ABA7),
);

NavigationAppBar buildNavigationAppBar(BuildContext context) {
  final brightness = FluentTheme.of(context).brightness;

  return NavigationAppBar(
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
              MinimizeWindowButton(
                colors: brightness == Brightness.light
                    ? _lightThemeColors
                    : _darkThemeColors,
              ),
              MaximizeWindowButton(
                colors: brightness == Brightness.light
                    ? _lightThemeColors
                    : _darkThemeColors,
              ),
              CloseWindowButton(
                colors: brightness == Brightness.light
                    ? _closeLightThemeColors
                    : _closeDarkThemeColors,
              ),
            ],
          )
        : null,
    automaticallyImplyLeading: false,
  );
}
