import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/form_layout.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_title.dart';
import 'forgot_password_sheet.dart';
import 'register_screen.dart';

/// Email / password sign-in. No navigation is needed after a successful
/// sign-in: SplashScreen switches to the home screen on its own.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Live validation only starts after the first submit attempt, so the user
  // is not shown errors while typing for the first time.
  var _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO(Dev 2): call AuthProvider.signIn() and set _errorMessage on failure.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion : logique à venir.')),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: FormLayout(
          children: [
            const SizedBox(height: 24),
            const AppLogo(),
            const SizedBox(height: 32),
            const ScreenTitle(
              title: 'Connexion',
              subtitle:
                  'Heureux de vous revoir ! Connectez-vous pour signaler et '
                  'suivre les problèmes de votre quartier.',
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              MessageBanner(
                text: _errorMessage!,
                onClose: () => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),
            ],
            Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        hintText: 'vous@exemple.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      validator: (value) => Validators.notEmpty(
                        value,
                        'Veuillez saisir votre mot de passe.',
                      ),
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () => ForgotPasswordSheet.show(context),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Se connecter',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
            // Wrap rather than Row: stays readable with large font settings.
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Pas encore de compte ?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _openRegister,
                  child: const Text('S\'inscrire'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
