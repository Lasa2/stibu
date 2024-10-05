import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/feature/app_state/account.dart';
import 'package:stibu/feature/navigation/windows_appbar.dart';
import 'package:stibu/main.dart';

@RoutePage()
class AuthenticationPage extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthenticationPage({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  int currentIndex = 0;

  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) => NavigationView(
        appBar: buildNavigationAppBar(context),
        content: ScaffoldPage(
          content: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TabView(
                  currentIndex: currentIndex,
                  showScrollButtons: false,
                  shortcutsEnabled: false,
                  onNewPressed: null,
                  closeButtonVisibility: CloseButtonVisibilityMode.never,
                  onChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  onReorder: null,
                  tabs: [
                    Tab(
                      text: const Text('Login'),
                      body: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          children: [
                            Card(
                              borderColor: Colors.transparent,
                              borderRadius: BorderRadius.zero,
                              child: LoginTab(
                                onAuthenticated: widget.onAuthenticated,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      text: const Text('Create Account'),
                      body: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          children: [
                            Card(
                              borderColor: Colors.transparent,
                              borderRadius: BorderRadius.zero,
                              child: CreateAccountTab(
                                onAuthenticated: widget.onAuthenticated,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class CreateAccountTab extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const CreateAccountTab({super.key, required this.onAuthenticated});

  @override
  State<CreateAccountTab> createState() => _CreateAccountTabState();
}

class _CreateAccountTabState extends State<CreateAccountTab> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;

  Future<void> onCreateAccount(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final result =
          await getIt<Authentication>().createAccount(email!, password!, name!);

      if (!context.mounted) return;
      await showResultInfo(context, result);

      if (result.isSuccess) {
        widget.onAuthenticated();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormBox(
                initialValue: name,
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
                onSaved: (newValue) => name = newValue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextFormBox(
                initialValue: email,
                placeholder: 'Email',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (newValue) => email = newValue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextFormBox(
                initialValue: password,
                placeholder: 'Password',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) async => onCreateAccount(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (newValue) => password = newValue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Button(
                onPressed: () async => onCreateAccount(context),
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      );
}

class LoginTab extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LoginTab({super.key, required this.onAuthenticated});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  Future<void> onLogin(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final result = await getIt<Authentication>().login(email!, password!);

      if (!context.mounted) return;
      await showResultInfo(context, result);

      if (result.isSuccess) {
        widget.onAuthenticated();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormBox(
                initialValue: email,
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
                onSaved: (newValue) => email = newValue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextFormBox(
                initialValue: password,
                placeholder: 'Password',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) async => onLogin(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (newValue) => password = newValue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Button(
                onPressed: () async => onLogin(context),
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      );
}
