import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_exception.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/form_layout.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_title.dart';

/// Sign-up with name, email and password. After a successful sign-up this
/// screen must be popped: SplashScreen then shows the home screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  var _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    try {
      await context.read<AuthProvider>().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      TextInput.finishAutofillContext();
      // SplashScreen already shows the home screen under this route.
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      // Light app bar on this onboarding screen: only the back arrow matters.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.primary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FormLayout(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const AppLogo(size: 56, showName: false),
          const SizedBox(height: 24),
          const ScreenTitle(
            title: 'Inscription',
            subtitle:
                'Créez votre compte pour signaler les dépôts sauvages et les '
                'caniveaux bouchés de votre quartier.',
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
                    controller: _nameController,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: Validators.name,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      hintText: 'Ex. Awa Koné',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    helperText:
                        'Au moins ${Validators.minPasswordLength} caractères',
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmation',
                    hint: 'Retapez votre mot de passe',
                    enabled: !_isLoading,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Votre nom sera affiché sur les signalements que vous publiez.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Créer mon compte',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Déjà un compte ?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
