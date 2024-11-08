import 'package:fluent_ui/fluent_ui.dart';

Future<void> scrollToIndex(
  int index, {
  required ScrollController controller,
  double itemExtent = 58,
}) async {
  final scrollOffset = controller.offset;

  final itemOffset = index * itemExtent;

  // If the item is already visible, do nothing
  if (itemOffset >= scrollOffset &&
      itemOffset + itemExtent <=
          scrollOffset + controller.position.viewportDimension) {
    return;
  }

  // If the item is above the current view, scroll up
  if (itemOffset < scrollOffset) {
    await controller.animateTo(
      itemOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return;
  }

  // If the item is below the current view, scroll down
  if (itemOffset + itemExtent >
      scrollOffset + controller.position.viewportDimension) {
    await controller.animateTo(
      itemOffset - controller.position.viewportDimension + itemExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return;
  }
}
