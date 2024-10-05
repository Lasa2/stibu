import 'package:fluent_ui/fluent_ui.dart';
import 'package:result_type/result_type.dart';

Future<void> showResultInfo<T>(
  BuildContext context,
  Result<T, String> result, {
  String? successMessage,
}) async {
  if (result.isFailure && context.mounted) {
    await displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('Error'),
        content: Text(result.failure),
        severity: InfoBarSeverity.error,
      ),
    );
  } else if (successMessage != null && context.mounted) {
    await displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('Success'),
        content: Text(successMessage),
        severity: InfoBarSeverity.success,
      ),
    );
  }
}
