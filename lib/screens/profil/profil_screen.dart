import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/avatar_initiales.dart';
import '../../widgets/logo_cleancity.dart';
import 'modifier_profil_screen.dart';

/// Onglet « Profil » : nom, email, nombre de signalements, déconnexion.
/// Après la déconnexion, inutile de naviguer : SplashScreen bascule tout seul
/// vers l'écran de connexion.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final couleurs = Theme.of(context).colorScheme;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexte) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour publier ou suivre vos '
          'signalements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexte, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: couleurs.error),
            onPressed: () => Navigator.pop(contexte, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirme != true || !context.mounted) return;

    // TODO(Dev 2): call AuthProvider.deconnecter().
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion : logique à venir.')),
    );
  }

  void _afficherAPropos(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (contexte) => AlertDialog(
        title: const Row(
          children: [
            LogoCleanCity(taille: 40, avecNom: false),
            SizedBox(width: 12),
            Text('CleanCity'),
          ],
        ),
        content: const Text(
          'Signalez les dépôts d\'ordures sauvages et les caniveaux bouchés '
          'à Abidjan, puis suivez leur résolution.\n\n'
          'Projet réalisé pour le Flufithon \'26, en lien avec les ODD 11 '
          '(villes durables) et 13 (climat).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexte),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;
    final utilisateur = context.watch<AuthProvider>().user;

    // TODO(Dev 2): read nom/role from users/{uid} and the signalement count.
    final nomFirebase = utilisateur?.displayName?.trim() ?? '';
    final nom = nomFirebase.isNotEmpty ? nomFirebase : 'Utilisateur CleanCity';
    final email = utilisateur?.email ?? '';
    const role = kRoleCitoyen;
    const nbSignalements = 0;
    final membreDepuis = utilisateur?.metadata.creationTime;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _EnTeteProfil(nom: nom, email: email, role: role),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TuileStatistique(
                  icone: Icons.flag_outlined,
                  valeur: '$nbSignalements',
                  libelle: 'Signalements',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TuileStatistique(
                  icone: Icons.calendar_today_outlined,
                  valeur: membreDepuis == null
                      ? '—'
                      : DateFormat.yMMM('fr_FR').format(membreDepuis),
                  libelle: 'Membre depuis',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _TitreSection('Compte'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Modifier le profil'),
                  subtitle: const Text('Changer le nom affiché'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ModifierProfilScreen(nom: nom, email: email),
                    ),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('À propos de CleanCity'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _afficherAPropos(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => _confirmerDeconnexion(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: couleurs.error,
              side: BorderSide(color: couleurs.error.withValues(alpha: 0.5)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
          const SizedBox(height: 16),
          Text(
            'CleanCity · version 1.0.0',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EnTeteProfil extends StatelessWidget {
  final String nom;
  final String email;
  final String role;

  const _EnTeteProfil({
    required this.nom,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AvatarInitiales(nom: nom, rayon: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _BadgeRole(role: role),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeRole extends StatelessWidget {
  final String role;

  const _BadgeRole({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;
    final estAdmin = role == kRoleAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: estAdmin
            ? couleurs.primaryContainer
            : couleurs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estAdmin ? Icons.verified_user_outlined : Icons.person_outline,
            size: 14,
            color: couleurs.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            estAdmin ? 'Administrateur' : 'Citoyen',
            style: theme.textTheme.labelMedium?.copyWith(
              color: couleurs.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TuileStatistique extends StatelessWidget {
  final IconData icone;
  final String valeur;
  final String libelle;

  const _TuileStatistique({
    required this.icone,
    required this.valeur,
    required this.libelle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: couleurs.secondary, size: 22),
            const SizedBox(height: 12),
            Text(
              valeur,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: couleurs.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(libelle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  final String titre;

  const _TitreSection(this.titre);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        titre,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
