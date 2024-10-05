import 'package:fluent_ui/fluent_ui.dart';

class CustomPageHeader extends StatelessWidget {
  /// Creates a page header.
  const CustomPageHeader({
    super.key,
    this.leading,
    this.title,
    this.commandBar,
    this.padding,
  });

  /// The widget displayed before the [title]
  ///
  /// Usually an [Icon] widget.
  final Widget? leading;

  /// The title of this bar.
  ///
  /// ![Header Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-header.png)
  ///
  /// Usually a [Text] widget.
  final Widget? title;

  /// A bar with a list of actions an user can take
  ///
  /// Usually a [CommandBar] widget.
  final Widget? commandBar;

  /// The horizontal padding applied to both sides of the page
  ///
  /// If not provided, the padding is calculated using the [horizontalPadding]
  /// function, which gets the padding based on the screen width.
  final double? padding;

  /// Gets the horizontal padding applied to the header based on the screen
  /// width.
  ///
  /// If the screen is small, the padding is 12.0, otherwise it defaults to
  /// [kPageDefaultVerticalPadding]
  static double horizontalPadding(BuildContext context) {
    assert(
      debugCheckHasMediaQuery(context),
      'A context with media query is required',
    );
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 640.0;
    final horizontalPadding =
        isSmallScreen ? 12.0 : kPageDefaultVerticalPadding;
    return horizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      debugCheckHasFluentTheme(context),
      'A context with FluentTheme is required',
    );
    final theme = FluentTheme.of(context);
    final horizontalPadding =
        padding ?? CustomPageHeader.horizontalPadding(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: 18,
        start: leading != null ? 0 : horizontalPadding,
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.typography.title,
              child: title ?? const SizedBox(),
            ),
          ),
          SizedBox(width: horizontalPadding),
          if (commandBar != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: commandBar,
              ),
            ),
            SizedBox(width: horizontalPadding),
          ],
        ],
      ),
    );
  }
}
