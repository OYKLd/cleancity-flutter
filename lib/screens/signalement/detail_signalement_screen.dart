import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../models/signalement.dart';
import '../../services/signalement_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/status_badge.dart';

class DetailSignalementScreen extends StatelessWidget {
  final Signalement signalement;

  const DetailSignalementScreen({super.key, required this.signalement});

  Future<void> _ouvrirGoogleMaps(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    // Si aucune application ne peut ouvrir le lien, on prévient
    // l'utilisateur au lieu de laisser une erreur silencieuse.
    final ouvert = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ouvert && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdmin = authProvider.isAdmin;

    final DateTime? date = signalement.createdAt;
    final String dateFormatted = date != null
        ? DateFormat('dd/MM/yyyy à HH:mm').format(date.toLocal())
        : 'Non renseignée';

    // Localisation : la commune si elle a été saisie à la main,
    // sinon on indique que la position GPS a été enregistrée.
    final String? commune = signalement.commune;
    final bool aPositionGps =
        signalement.latitude != null && signalement.longitude != null;
    final String localisationText =
        (commune != null && commune.trim().isNotEmpty)
        ? 'Commune : $commune'
        : aPositionGps
        ? 'Position GPS enregistrée'
        : 'Localisation non renseignée';

    final String? repere = signalement.repere;

    // Type changé de 'String?' vers 'String' pour enlever le dernier warning
    final String nomAuteur = signalement.userNom;
    final String nomAuteurAffiche = nomAuteur.trim().isNotEmpty
        ? nomAuteur
        : 'Anonyme';

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du signalement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo du signalement
            if (signalement.photoBase64.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(signalement.photoBase64),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),

            // Badges : Catégorie & Statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(libelleCategorie(signalement.categorie)),
                ),
                StatusBadge(statut: signalement.statut),
              ],
            ),
            const SizedBox(height: 12),

            // Urgence
            Chip(
              label: Text(
                libelleUrgence(signalement.urgence),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: couleurUrgence(signalement.urgence),
            ),
            const SizedBox(height: 12),

            // Auteur & Date
            Text(
              'Auteur : $nomAuteurAffiche',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Date : $dateFormatted',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Localisation
            Text(
              localisationText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (repere != null && repere.isNotEmpty) Text('Repère : $repere'),
            const SizedBox(height: 12),

            // Description
            Text(
              'Description :',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(signalement.description),
            const SizedBox(height: 16),

            // Bouton Google Maps
            if (signalement.latitude != null && signalement.longitude != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Voir sur Google Maps'),
                  onPressed: () => _ouvrirGoogleMaps(
                    context,
                    signalement.latitude!,
                    signalement.longitude!,
                  ),
                ),
              ),

            // Section Admin
            if (isAdmin) ...[
              const Divider(height: 32),
              Text(
                'Gestion Admin - Modifier le statut :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              // Les boutons du thème ont une largeur minimale infinie :
              // dans une Row, chacun doit être dans un Expanded pour
              // se partager la largeur (sinon la page reste blanche).
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _changerStatut(context, 'en_cours'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('En cours'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _changerStatut(context, 'resolu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Résolu'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _changerStatut(BuildContext context, String nouveauStatut) async {
    try {
      await SignalementService().changerStatut(signalement.id, nouveauStatut);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Statut mis à jour : ${libelleStatut(nouveauStatut)}',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de mettre à jour le statut. Veuillez réessayer.',
            ),
          ),
        );
      }
    }
  }
}
