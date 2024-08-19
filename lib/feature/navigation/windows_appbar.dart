import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

NavigationAppBar buildNavigationAppBar(BuildContext context) =>
    NavigationAppBar(
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
      automaticallyImplyLeading: false,
    );
