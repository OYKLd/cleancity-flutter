import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_exception.dart';
import '../../utils/validators.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/leaf_backdrop.dart';
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
    final colors = theme.colorScheme;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Modifier le profil'),
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: LeafBackdrop(topRight: false)),
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AvatarBanner(name: _nameController.text),
                  const SizedBox(height: 12),
                  Text(
                    'Les initiales sont générées à partir de votre nom.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              MessageBanner(
                                text: _errorMessage!,
                                onClose: () =>
                                    setState(() => _errorMessage = null),
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
                                    textCapitalization:
                                        TextCapitalization.words,
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
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Adresse email',
                                      prefixIcon: const Icon(
                                        Icons.mail_outline,
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                      ),
                                      fillColor: colors.surfaceContainer,
                                      helperText:
                                          'L\'adresse email ne peut pas être '
                                          'modifiée.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const MessageBanner(
                              text:
                                  'Ce nom apparaît sur vos signalements et '
                                  'dans votre profil.',
                              type: BannerType.info,
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
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.maybePop(context),
                              child: const Text('Annuler'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient banner under the transparent app bar, with the avatar sitting
/// on its bottom edge like the stats card on the profile screen.
class _AvatarBanner extends StatelessWidget {
  static const double _avatarRadius = 48;
  static const double _ring = 4;

  final String name;

  const _AvatarBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Read inside the body: with extendBodyBehindAppBar, the Scaffold adds
    // the app bar height to this inset for its body only.
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          bottom: _avatarRadius + _ring,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: topInset + 16),
            Container(
              padding: const EdgeInsets.all(_ring),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InitialsAvatar(name: name, radius: _avatarRadius),
            ),
          ],
        ),
      ],
    );
  }
}
