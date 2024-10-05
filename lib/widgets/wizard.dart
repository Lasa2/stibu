import 'package:fluent_ui/fluent_ui.dart';

class WizardStep {
  final IconData? icon;
  final IconData? iconCurrent;
  final IconData? iconCompleted;
  final String title;
  final Widget content;

  const WizardStep({
    this.icon,
    this.iconCurrent,
    this.iconCompleted,
    required this.title,
    required this.content,
  });
}

class Wizard extends StatefulWidget {
  const Wizard({
    super.key,
    required this.pages,
    this.onFinish,
  });

  final List<WizardStep> pages;
  final void Function()? onFinish;

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      widget.onFinish?.call();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Widget buildOverviewRow(BuildContext context) {
    // This widget is used to display the overview of the wizard
    // which consists of a row of circles with the step number, each representing a page
    // the circles are divided by a line
    // under each circle there is the title of the page

    final theme = FluentTheme.of(context);

    final items = List<Widget>.generate(widget.pages.length, (index) {
      final step = widget.pages[index];
      final isCurrent = index == _currentPage;
      final isCompleted = index < _currentPage;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCurrent || isCompleted
                  ? theme.accentColor
                  : Colors.transparent,
              border: Border.all(
                color: theme.accentColor,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      FluentIcons.check_mark,
                      size: 16,
                      color: theme.resources.textOnAccentFillColorPrimary,
                    )
                  : Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent || isCompleted
                            ? theme.resources.textOnAccentFillColorPrimary
                            : theme.resources.textFillColorPrimary,
                      ),
                    ),
            ),
          ),
          if (index < widget.pages.length - 1)
            Flexible(
              child: Container(
                height: 2,
                color: isCompleted ? theme.accentColor : theme.inactiveColor,
              ),
            ),
          Text(
            step.title,
          ),
        ],
      );
    });

    // add separators between the items
    // the separators are lines with a width of 16

    for (var i = 1; i < items.length; i += 2) {
      items.insert(
        i,
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 16,
          height: 2,
          color: theme.inactiveColor,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          buildOverviewRow(context),
          Expanded(
            child: widget.pages[_currentPage].content,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Button(
                    onPressed: _previousPage,
                    child: const Text('Previous'),
                  ),
                ),
              Button(
                onPressed: _nextPage,
                child: Text(
                  _currentPage < widget.pages.length - 1 ? 'Next' : 'Finish',
                ),
              ),
            ],
          ),
        ],
      );
}
