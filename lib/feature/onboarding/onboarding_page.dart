import 'dart:convert';

import 'package:appwrite/enums.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/feature/app_state/theme.dart';
import 'package:stibu/feature/navigation/windows_appbar.dart';
import 'package:stibu/main.dart';
import 'package:stibu/widgets/wizard.dart';
import 'package:system_theme/system_theme.dart';

@RoutePage()
class OnboardingPage extends StatelessWidget {
  final void Function()? onFinish;

  const OnboardingPage({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: buildNavigationAppBar(context),
      content: ScaffoldPage(
        content: Wizard(
            onFinish: () async {
              final appwrite = getIt<AppwriteClient>();

              final preferences = await appwrite.account.getPrefs();

              preferences.data['onboardingCompleted'] = true;

              await appwrite.account.updatePrefs(prefs: preferences.data);

              onFinish?.call();
            },
            pages: [
              const WizardStep(
                title: 'Welcome to Stibu',
                content: Column(
                  children: [
                    Text(
                      'Welcome to Stibu, the best way to manage your tasks!',
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'This wizard will guide you through the basic features of Stibu.',
                    ),
                  ],
                ),
              ),
              const WizardStep(
                title: 'Enter Product Key',
                content: ProductKeyTab(),
              ),
              WizardStep(
                title: 'Select accent color and theme mode',
                content: ThemeAndAccentColorSelection(
                  onAccentColorChanged: (color) {
                    final themeProvider = getIt<ThemeProvider>();
                    themeProvider.accentColor = color;
                  },
                  onThemeModeChanged: (mode) {
                    final themeProvider = getIt<ThemeProvider>();
                    themeProvider.themeMode = mode;
                  },
                ),
              ),
              WizardStep(
                title: 'That\'s it!',
                content: Column(
                  children: [
                    Text(
                      'You\'re all set! Click Finish to start using Stibu.',
                      style: FluentTheme.of(context).typography.title,
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}

class ProductKeyTab extends StatefulWidget {
  final void Function()? onFinish;

  const ProductKeyTab({super.key, this.onFinish});

  @override
  State<ProductKeyTab> createState() => _ProductKeyTabState();
}

class _ProductKeyTabState extends State<ProductKeyTab> {
  final formKey = GlobalKey<FormState>();
  final productKeyController = TextEditingController();
  bool readOnly = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormBox(
                readOnly: readOnly,
                controller: productKeyController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product key';
                  }
                  return null;
                },
                placeholder: 'Product key',
              ),
              const SizedBox(height: 16.0),
              if (readOnly)
                const Text(
                  'Product key confirmed!',
                ),
              if (!readOnly)
                Button(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final productKey = productKeyController.text.trim();

                      final appwrite = getIt<AppwriteClient>();

                      final result = await appwrite.functions.createExecution(
                        functionId: '66e340510031daaffc90',
                        method: ExecutionMethod.gET,
                        headers: {
                          'product-key': productKey,
                        },
                      );

                      if (result.responseStatusCode != 200) {
                        if (!context.mounted) return;
                        displayInfoBar(context,
                            builder: (context, close) => InfoBar(
                                  title: const Text('Server error'),
                                  content: Text(result.responseBody),
                                  severity: InfoBarSeverity.error,
                                  onClose: close,
                                ));
                        return;
                      }

                      final map = jsonDecode(result.responseBody)
                          as Map<String, dynamic>;

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
                        setState(() => readOnly = true);
                        widget.onFinish?.call();
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeAndAccentColorSelection extends StatefulWidget {
  final void Function(AccentColor)? onAccentColorChanged;
  final void Function(ThemeMode)? onThemeModeChanged;

  const ThemeAndAccentColorSelection(
      {super.key, this.onAccentColorChanged, this.onThemeModeChanged});

  @override
  State<ThemeAndAccentColorSelection> createState() =>
      _ThemeAndAccentColorSelectionState();
}

class _ThemeAndAccentColorSelectionState
    extends State<ThemeAndAccentColorSelection> {
  final colors = List.unmodifiable(
      [...Colors.accentColors, SystemTheme.accentColor.accent.toAccentColor()]);
  ThemeMode themeMode = getIt<ThemeProvider>().themeMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Select an accent color for Stibu.',
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in colors)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => widget.onAccentColorChanged?.call(color),
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text(
            'Select a theme mode for Stibu.',
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ComboBox<ThemeMode>(
              value: themeMode,
              items: ThemeMode.values
                  .map((e) => ComboBoxItem<ThemeMode>(
                        key: Key(e.toString()),
                        value: e,
                        child: Text(e.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => themeMode = value!);
                widget.onThemeModeChanged?.call(value!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
