import 'dart:convert';

import 'package:appwrite/enums.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/navigation/windows_appbar.dart';
import 'package:stibu/main.dart';

@RoutePage()
class ProductKeyPage extends StatefulWidget {
  final void Function()? onFinish;

  const ProductKeyPage({
    super.key,
    this.onFinish,
  });

  @override
  State<ProductKeyPage> createState() => _ProductKeyPageState();
}

class _ProductKeyPageState extends State<ProductKeyPage> {
  final productKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: buildNavigationAppBar(context),
      content: ScaffoldPage(
        header: const PageHeader(
          title: Text('Enter your product key'),
        ),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                TextBox(
                  controller: productKeyController,
                  placeholder: 'Product key',
                ),
                const SizedBox(height: 16.0),
                Button(
                  onPressed: () async {
                    final appwrite = getIt<AppwriteClient>();

                    final result = await appwrite.functions.createExecution(
                      functionId: '66e340510031daaffc90',
                      method: ExecutionMethod.gET,
                      headers: {
                        'product-key': productKeyController.text.trim(),
                      },
                    );

                    final map =
                        jsonDecode(result.responseBody) as Map<String, dynamic>;

                    if (map['status'] != 200) {
                      if (!context.mounted) return;
                      displayInfoBar(context,
                          builder: (context, close) => InfoBar(
                                title: const Text('Invalid product key'),
                                content: const Text(
                                    'The product key you entered is invalid. Please try again.'),
                                severity: InfoBarSeverity.error,
                                onClose: close,
                              ));
                    } else {
                      widget.onFinish?.call();
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
