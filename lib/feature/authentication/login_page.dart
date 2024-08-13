import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:june/june.dart';
import 'package:stibu/feature/authentication/auth_state.dart';
import 'package:stibu/router.gr.dart';
import 'package:stibu/widgets/text_box_form.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  final void Function(bool success)? onResult;
  const LoginPage({super.key, this.onResult});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        automaticallyImplyLeading: false,
      ),
      content: ScaffoldPage(
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Login'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: TextBoxForm(
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
                  child: TextBoxForm(
                    controller: passwordController,
                    placeholder: 'Password',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
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
                        return;
                      }

                      final email = emailController.text;
                      final password = passwordController.text;

                      final auth = June.getState(() => Auth());
                      await auth.login(email, password);

                      widget.onResult?.call(auth.isAuthenticated);
                    },
                    child: const Text('Login'),
                  ),
                ),
                Button(
                  onPressed: () {
                    context.router.push(const CreateAccountRoute());
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
