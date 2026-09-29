import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/signalement.dart';
import '../services/signalement_service.dart';
import '../providers/auth_provider.dart';

class DetailScreen extends StatelessWidget {
  final Signalement signalement;

  const DetailScreen({super.key, required this.signalement});

  Future<void> _ouvrirGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du signalement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(signalement.categorie.toUpperCase())),
                Chip(
                  label: Text(signalement.statut.replaceAll('_', ' ').toUpperCase()),
                  backgroundColor: signalement.statut == 'resolu'
                      ? Colors.green[100]
                      : (signalement.statut == 'en_cours' ? Colors.orange[100] : Colors.grey[200]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Commune : ${signalement.commune}', style: Theme.of(context).textTheme.titleMedium),
            if (signalement.repere != null && signalement.repere!.isNotEmpty)
              Text('Repère : ${signalement.repere}'),
            const SizedBox(height: 8),
            Text('Description :', style: Theme.of(context).textTheme.titleSmall),
            Text(signalement.description),
            const SizedBox(height: 16),
            if (signalement.latitude != null && signalement.longitude != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Voir sur Google Maps'),
                  onPressed: () => _ouvrirGoogleMaps(signalement.latitude!, signalement.longitude!),
                ),
              ),
            if (isAdmin) ...[
              const Divider(height: 32),
              Text('Gestion Admin - Modifier le statut :', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _changerStatut(context, 'en_cours'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('En cours'),
                  ),
                  ElevatedButton(
                    onPressed: () => _changerStatut(context, 'resolu'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Résolu'),
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
          SnackBar(content: Text('Statut mis à jour : ${nouveauStatut.replaceAll('_', ' ')}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de mise à jour : $e')),
        );
      }
    }
  }
}