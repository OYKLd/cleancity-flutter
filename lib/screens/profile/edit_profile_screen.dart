import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_exception.dart';
import '../../utils/validators.dart';
import '../../widgets/form_layout.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/primary_button.dart';

/// Profile editing: only the display name can be changed. The email stays
/// read-only because changing it would require re-authentication.
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  var _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _hasChanges => _nameController.text.trim() != widget.name.trim();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    // The avatar initials and the save button both follow the typed value.
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().updateName(
        _nameController.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil mis à jour.')),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDiscard() async {
    if (_isLoading) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abandonner les modifications ?'),
        content: const Text('Le nouveau nom ne sera pas enregistré.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continuer la saisie'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: FormLayout(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Center(
              child: InitialsAvatar(name: _nameController.text, radius: 44),
            ),
            const SizedBox(height: 10),
            Text(
              'Les initiales sont générées à partir de votre nom.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 28),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    validator: Validators.name,
                    onFieldSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Adresse email',
                      prefixIcon: Icon(Icons.mail_outline),
                      helperText: 'L\'adresse email ne peut pas être modifiée.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Enregistrer',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _hasChanges ? _save : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.maybePop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
