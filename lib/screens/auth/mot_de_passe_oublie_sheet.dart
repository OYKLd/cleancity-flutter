import 'package:flutter/material.dart';

import '../../utils/validateurs.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/titre_ecran.dart';

/// Bottom sheet to request a password reset link by email.
class MotDePasseOublieSheet extends StatefulWidget {
  const MotDePasseOublieSheet({super.key});

  static Future<void> afficher(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const MotDePasseOublieSheet(),
    );
  }

  @override
  State<MotDePasseOublieSheet> createState() => _MotDePasseOublieSheetState();
}

class _MotDePasseOublieSheetState extends State<MotDePasseOublieSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  var _modeValidation = AutovalidateMode.disabled;
  bool _enCours = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    setState(() => _modeValidation = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enCours = true);

    // TODO(Dev 2): call AuthService to send the reset email.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Réinitialisation : logique à venir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hauteurClavier = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + hauteurClavier),
      child: Form(
        key: _formKey,
        autovalidateMode: _modeValidation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TitreEcran(
              titre: 'Mot de passe oublié',
              sousTitre:
                  'Indiquez votre adresse email : nous vous enverrons un lien '
                  'pour choisir un nouveau mot de passe.',
              compact: true,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              enabled: !_enCours,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              validator: Validateurs.email,
              onFieldSubmitted: (_) => _envoyer(),
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                hintText: 'vous@exemple.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 24),
            BoutonPrincipal(
              libelle: 'Envoyer le lien',
              icone: Icons.send_outlined,
              enCours: _enCours,
              onPressed: _envoyer,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _enCours ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
