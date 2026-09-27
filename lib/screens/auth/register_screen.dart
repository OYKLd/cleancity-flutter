import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validators.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/form_layout.dart';
import '../../widgets/password_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/screen_title.dart';

/// Écran d'inscription (nom, email, mot de passe).
/// Après l'inscription, penser à fermer cet écran (Navigator.pop) :
/// SplashScreen affichera alors l'accueil.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmationController = TextEditingController();

  var _modeValidation = AutovalidateMode.disabled;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _confirmationController.dispose();
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

    // TODO(Dev 2): call AuthProvider.inscrire() and set _erreur on failure.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _enCours = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscription : logique à venir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;

    return Scaffold(
      // Light app bar on this onboarding screen: only the back arrow matters.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: couleurs.primary,
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
                    controller: _nomController,
                    enabled: !_enCours,
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
                    helperText:
                        'Au moins ${Validators.minPasswordLength} '
                        'caractères',
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmationController,
                    label: 'Confirmation',
                    hint: 'Retapez votre mot de passe',
                    enabled: !_enCours,
                    validator: (valeur) => Validators.confirmPassword(
                      valeur,
                      _motDePasseController.text,
                    ),
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _soumettre(),
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
            isLoading: _enCours,
            onPressed: _soumettre,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Déjà un compte ?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: couleurs.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: _enCours ? null : () => Navigator.pop(context),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
