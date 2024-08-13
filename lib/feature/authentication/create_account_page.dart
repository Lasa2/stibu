import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/main.dart';

@RoutePage()
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                  child: TextBox(
                    controller: nameController,
                    placeholder: 'Name',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: TextBox(
                    controller: emailController,
                    placeholder: 'Email',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: TextBox(
                    controller: passwordController,
                    placeholder: 'Password',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Button(
                    onPressed: () async {
                      final account = Account(client);

                      try {
                        final result = await account.create(
                          userId: ID.unique(),
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        log.info('Account created: $result');
                        if (context.mounted) {
                          await displayInfoBar(context,
                              duration: const Duration(seconds: 5),
                              builder: (context, close) {
                            return InfoBar(
                              title: const Text('Success'),
                              content:
                                  const Text('Account created successfully'),
                              action: IconButton(
                                icon: const Icon(FluentIcons.clear),
                                onPressed: close,
                              ),
                              severity: InfoBarSeverity.success,
                            );
                          });
                          if (context.mounted) context.router.maybePop();
                        }
                      } on AppwriteException catch (e) {
                        log.severe(e.message);

                        if (context.mounted && e.message != null) {
                          await displayInfoBar(context,
                              duration: const Duration(seconds: 5),
                              builder: (context, close) {
                            return InfoBar(
                              title: const Text('Error'),
                              content: Text(e.message!),
                              action: IconButton(
                                icon: const Icon(FluentIcons.clear),
                                onPressed: close,
                              ),
                              severity: InfoBarSeverity.error,
                            );
                          });
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
