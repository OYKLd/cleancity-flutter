import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_exception.dart';
import '../../utils/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/initials_avatar.dart';
import 'edit_profile_screen.dart';

/// "Profil" tab: name, email, report count and sign-out. No navigation is
/// needed after signing out: SplashScreen switches to the login screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<int> _reportCount;

  @override
  void initState() {
    super.initState();
    _reportCount = context.read<AuthProvider>().countReports();
  }

  // The count comes from an aggregation query, not a live stream, so the
  // user refreshes it by pulling the page down.
  Future<void> _refreshReportCount() async {
    setState(() => _reportCount = context.read<AuthProvider>().countReports());
    try {
      await _reportCount;
    } on AuthException {
      // The tile already shows a dash on error.
    }
  }

  void _openEditProfile(String name, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(name: name, email: email),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour publier ou suivre vos '
          'signalements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<AuthProvider>().signOut();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            AppLogo(size: 40, showName: false),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatCount(AsyncSnapshot<int> snapshot) {
    if (snapshot.hasError) return '—';
    if (!snapshot.hasData) return '…';
    return '${snapshot.data}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final topInset = MediaQuery.paddingOf(context).top;

    final name = auth.displayName;
    final email = auth.email;
    final role = auth.profile?.role ?? kRoleCitoyen;
    final memberSince =
        auth.profile?.createdAt ?? auth.user?.metadata.creationTime;

    // The header is painted under the status bar, so its icons must be light.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshReportCount,
          edgeOffset: topInset,
          child: ListView(
            // Always scrollable so pull-to-refresh works on a short page.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _HeaderWithStats(
                header: _HeaderContent(
                  name: name,
                  email: email,
                  role: role,
                  topInset: topInset,
                  onEdit: () => _openEditProfile(name, email),
                ),
                stats: FutureBuilder<int>(
                  future: _reportCount,
                  builder: (context, snapshot) => _StatsCard(
                    reportCount: _formatCount(snapshot),
                    memberSince: memberSince == null
                        ? '—'
                        : DateFormat.yMMM('fr_FR').format(memberSince),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle('Compte'),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.edit_outlined,
                          title: 'Modifier le profil',
                          subtitle: 'Changer le nom affiché',
                          onTap: () => _openEditProfile(name, email),
                        ),
                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: 'À propos de CleanCity',
                          subtitle: 'ODD 11 et 13, Flufithon \'26',
                          onTap: _showAbout,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SignOutButton(onPressed: _confirmSignOut),
                    const SizedBox(height: 16),
                    Text(
                      'CleanCity · version 1.0.0',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient banner behind [header], extending under the top part of [stats]
/// so the card looks like it floats over the banner edge. Both are laid out
/// in a column, so the banner never hides any header content.
class _HeaderWithStats extends StatelessWidget {
  static const double _bannerBleed = 56;

  final Widget header;
  final Widget stats;

  const _HeaderWithStats({required this.header, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          bottom: _bannerBleed,
          child: Container(
            clipBehavior: Clip.antiAlias,
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
            header,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: stats,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final double topInset;
  final VoidCallback onEdit;

  const _HeaderContent({
    required this.name,
    required this.email,
    required this.role,
    required this.topInset,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onBanner = Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, topInset + 12, 24, 24),
      child: Column(
        children: [
          Text(
            'Profil',
            style: theme.textTheme.titleMedium?.copyWith(color: onBanner),
          ),
          const SizedBox(height: 18),
          _EditableAvatar(name: name, onEdit: onEdit),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(color: onBanner),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onBanner.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          _RoleChip(role: role),
        ],
      ),
    );
  }
}

/// Avatar with a white ring and a small pencil badge opening the editor.
class _EditableAvatar extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;

  const _EditableAvatar({required this.name, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: InitialsAvatar(name: name, radius: 40),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton.filled(
            onPressed: onEdit,
            tooltip: 'Modifier le profil',
            iconSize: 15,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = role == kRoleAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified_user_outlined : Icons.person_outline,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isAdmin ? 'Administrateur' : 'Citoyen',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Two key figures side by side.
class _StatsCard extends StatelessWidget {
  final String reportCount;
  final String memberSince;

  const _StatsCard({required this.reportCount, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.flag_outlined,
                value: reportCount,
                label: 'Signalements',
              ),
            ),
            const VerticalDivider(width: 1, indent: 8, endIndent: 8),
            Expanded(
              child: _Stat(
                icon: Icons.calendar_today_outlined,
                value: memberSince,
                label: 'Membre depuis',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 72, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(title),
      titleTextStyle: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      subtitle: Text(subtitle),
      subtitleTextStyle: theme.textTheme.bodySmall,
      trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FilledButton.tonalIcon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.error.withValues(alpha: 0.08),
        foregroundColor: colors.error,
      ),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('Se déconnecter'),
    );
  }
}
