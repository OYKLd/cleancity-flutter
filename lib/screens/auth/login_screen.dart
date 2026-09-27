import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validators.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/form_layout.dart';
import '../../widgets/password_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/screen_title.dart';
import 'mot_de_passe_oublie_sheet.dart';
import 'register_screen.dart';

/// Écran de connexion (email / mot de passe).
/// Après une connexion réussie, inutile de naviguer : SplashScreen bascule
/// tout seul vers l'accueil.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // Live validation only starts after the first submit attempt, so the user
  // is not shown errors while typing for the first time.
  var _modeValidation = AutovalidateMode.disabled;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    FocusScope.of(context).unfocus();
    setState(() => _modeValidation = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    // TODO(Dev 2): call AuthProvider.connecter() and set _erreur on failure.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _enCours = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion : logique à venir.')),
    );
  }

  void _ouvrirInscription() {
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
            if (_erreur != null) ...[
              MessageBanner(
                text: _erreur!,
                onClose: () => setState(() => _erreur = null),
              ),
              const SizedBox(height: 16),
            ],
            Form(
              key: _formKey,
              autovalidateMode: _modeValidation,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      enabled: !_enCours,
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
                      controller: _motDePasseController,
                      enabled: !_enCours,
                      validator: (valeur) => Validators.notEmpty(
                        valeur,
                        'Veuillez saisir votre mot de passe.',
                      ),
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _soumettre(),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _enCours
                    ? null
                    : () => MotDePasseOublieSheet.afficher(context),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Se connecter',
              isLoading: _enCours,
              onPressed: _soumettre,
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
                  onPressed: _enCours ? null : _ouvrirInscription,
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
