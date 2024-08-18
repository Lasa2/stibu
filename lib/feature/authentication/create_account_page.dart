import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/feature/authentication/repository.dart';
import 'package:stibu/feature/router/router.gr.dart';
import 'package:stibu/main.dart';

@RoutePage()
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(),
      content: ScaffoldPage(
        content: Form(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(8), child: Text('Create Account')),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: TextFormBox(
                    controller: nameController,
                    placeholder: 'Name',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: TextFormBox(
                    controller: emailController,
                    placeholder: 'Email',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: TextFormBox(
                    controller: passwordController,
                    placeholder: 'Password',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Button(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) {
                        log.info('Form is invalid');
                        return;
                      }

                      final name = nameController.text;
                      final email = emailController.text;
                      final password = passwordController.text;

                      final auth = getIt<AuthState>();
                      final result =
                          await auth.createAccount(name, email, password);

                      if (context.mounted) {
                        await displayInfoBar(context,
                            builder: (context, close) => InfoBar(
                                  title: Text(result.isSuccess
                                      ? 'Account created successfully'
                                      : 'Failed to create account'),
                                  content:
                                      result.isSuccess
                                      ? null
                                      : Text(result.failure ?? ''),
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                  severity: result.isSuccess
                                      ? InfoBarSeverity.success
                                      : InfoBarSeverity.error,
                                ));

                        if (result.isSuccess) {
                          final result = await auth.login(email, password);
                          if (result.isSuccess) {
                            if (context.mounted) {
                              context.router
                                  .replaceAll([const DashboardRoute()]);
                            }
                          } else if (context.mounted) {
                            await displayInfoBar(context,
                                builder: (context, close) => InfoBar(
                                      title: const Text('Failed to login'),
                                      content: Text(result.failure ?? ''),
                                      action: IconButton(
                                        icon: const Icon(FluentIcons.clear),
                                        onPressed: close,
                                      ),
                                      severity: InfoBarSeverity.error,
                                    ));
                            if (context.mounted) context.router.maybePop();
                          }
                        }
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
