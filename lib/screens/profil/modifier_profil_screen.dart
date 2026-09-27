import 'package:flutter/material.dart';

import '../../utils/validateurs.dart';
import '../../widgets/avatar_initiales.dart';
import '../../widgets/bandeau_message.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/cadre_formulaire.dart';

/// Modification du profil : seul le nom affiché est modifiable.
/// L'email reste en lecture seule (le changer exigerait une reconnexion).
class ModifierProfilScreen extends StatefulWidget {
  final String nom;
  final String email;

  const ModifierProfilScreen({
    super.key,
    required this.nom,
    required this.email,
  });

  @override
  State<ModifierProfilScreen> createState() => _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends State<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;

  var _modeValidation = AutovalidateMode.disabled;
  bool _enCours = false;
  String? _erreur;

  bool get _modifie => _nomController.text.trim() != widget.nom.trim();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nom);
    // The avatar initials and the save button both follow the typed value.
    _nomController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    FocusScope.of(context).unfocus();
    setState(() => _modeValidation = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    // TODO(Dev 2): update users/{uid}.nom through AuthService.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Profil : enregistrement à venir.')),
    );
  }

  Future<void> _confirmerAbandon() async {
    if (_enCours) return;
    final quitter = await showDialog<bool>(
      context: context,
      builder: (contexte) => AlertDialog(
        title: const Text('Abandonner les modifications ?'),
        content: const Text('Le nouveau nom ne sera pas enregistré.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexte, false),
            child: const Text('Continuer la saisie'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexte, true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
    if (quitter == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_modifie,
      onPopInvokedWithResult: (aQuitte, _) {
        if (!aQuitte) _confirmerAbandon();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: CadreFormulaire(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Center(child: AvatarInitiales(nom: _nomController.text, rayon: 44)),
            const SizedBox(height: 10),
            Text(
              'Les initiales sont générées à partir de votre nom.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 28),
            if (_erreur != null) ...[
              BandeauMessage(
                texte: _erreur!,
                onFermer: () => setState(() => _erreur = null),
              ),
              const SizedBox(height: 16),
            ],
            Form(
              key: _formKey,
              autovalidateMode: _modeValidation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomController,
                    enabled: !_enCours,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    validator: Validateurs.nom,
                    onFieldSubmitted: (_) => _enregistrer(),
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
            BoutonPrincipal(
              libelle: 'Enregistrer',
              icone: Icons.check,
              enCours: _enCours,
              onPressed: _modifie ? _enregistrer : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _enCours ? null : () => Navigator.maybePop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
