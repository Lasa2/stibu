import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stibu/l10n/generated/l10n.dart';
import 'package:stibu/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signIn() async {
    final supabase = Supabase.instance.client;

    if (_formKey.currentContext == null || !_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      log.info('Sign in response: $response');
    } on AuthApiException catch (e) {
      log.severe('Sign in error: $e');
    }
    // context.router.pushNamed('/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Lang.of(context).appName)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      Lang.of(context).labelsLogin,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: Lang.of(context).labelsEmail),
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty
                          ? Lang.of(context).constraintsRequired
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: Lang.of(context).labelsPassword),
                      autofillHints: const [AutofillHints.password],
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) => value == null || value.isEmpty
                          ? Lang.of(context).constraintsRequired
                          : null,
                      onFieldSubmitted: (_) => _signIn(),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: Text(Lang.of(context).actionLogin),
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
}
