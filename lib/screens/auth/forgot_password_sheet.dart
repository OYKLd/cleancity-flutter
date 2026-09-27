import 'package:flutter/material.dart';

import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_title.dart';

/// Bottom sheet to request a password reset link by email.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ForgotPasswordSheet(),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  var _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + keyboardInset),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenTitle(
              title: 'Mot de passe oublié',
              subtitle:
                  'Indiquez votre adresse email : nous vous enverrons un lien '
                  'pour choisir un nouveau mot de passe.',
              compact: true,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              enabled: !_isLoading,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              validator: Validators.email,
              onFieldSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                hintText: 'vous@exemple.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Envoyer le lien',
              icon: Icons.send_outlined,
              isLoading: _isLoading,
              onPressed: _send,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
