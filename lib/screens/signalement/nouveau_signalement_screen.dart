import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/signalement.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_service.dart';
import '../../services/signalement_service.dart';
import '../../utils/constants.dart';

/// Création d'un signalement : photo, catégorie, urgence, description.
/// GPS et analyse IA seront ajoutés dans une prochaine étape (Dev 3 / Dev 5).
class NouveauSignalementScreen extends StatefulWidget {
  const NouveauSignalementScreen({super.key});

  @override
  State<NouveauSignalementScreen> createState() =>
      _NouveauSignalementScreenState();
}

class _NouveauSignalementScreenState extends State<NouveauSignalementScreen> {
  final ImageService _imageService = ImageService();
  final SignalementService _signalementService = SignalementService();
  final TextEditingController _descriptionController = TextEditingController();

  String? _photoBase64;
  String? _categorieChoisie;
  String? _urgenceChoisie;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      final base64 = await _imageService.choisirPhoto(source);
      if (base64 == null) return; // L'utilisateur a annulé.
      setState(() => _photoBase64 = base64);
    } catch (e) {
      _afficherErreur(e.toString());
    }
  }

  Future<void> _envoyerSignalement() async {
    if (_photoBase64 == null) {
      _afficherErreur('Ajoutez une photo du problème.');
      return;
    }
    if (_categorieChoisie == null) {
      _afficherErreur('Choisissez une catégorie.');
      return;
    }
    if (_urgenceChoisie == null) {
      _afficherErreur("Choisissez un niveau d'urgence.");
      return;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _afficherErreur('Décrivez brièvement le problème.');
      return;
    }

    final utilisateur = context.read<AuthProvider>().user;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour signaler un problème.');
      return;
    }

    setState(() => _envoiEnCours = true);
    try {
      final signalement = Signalement(
        userId: utilisateur.uid,
        // En attendant que Dev 2 ajoute le profil complet (nom) à
        // AuthProvider, on utilise le nom Firebase ou, à défaut, l'email.
        userNom: (utilisateur.displayName?.trim().isNotEmpty ?? false)
            ? utilisateur.displayName!.trim()
            : (utilisateur.email?.split('@').first ?? 'Utilisateur'),
        description: description,
        photoBase64: _photoBase64!,
        categorie: _categorieChoisie!,
        urgence: _urgenceChoisie!,
      );
      await _signalementService.creerSignalement(signalement);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement envoyé, merci !')),
      );
      Navigator.pop(context);
    } catch (e) {
      _afficherErreur("Erreur lors de l'envoi : $e");
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau signalement')),
      body: AbsorbPointer(
        absorbing: _envoiEnCours,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _blocPhoto(context),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _categorieChoisie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: kCategories.entries
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: _envoiEnCours
                  ? null
                  : (valeur) => setState(() => _categorieChoisie = valeur),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _urgenceChoisie,
              decoration: const InputDecoration(labelText: 'Urgence'),
              items: kUrgences.entries
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: _envoiEnCours
                  ? null
                  : (valeur) => setState(() => _urgenceChoisie = valeur),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 300,
              enabled: !_envoiEnCours,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: "Ex. : tas d'ordures depuis plusieurs jours...",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _envoiEnCours ? null : _envoyerSignalement,
              icon: _envoiEnCours
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _envoiEnCours ? 'Envoi en cours...' : 'Envoyer le signalement',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blocPhoto(BuildContext context) {
    final couleurFond = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: [
        if (_photoBase64 != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(_photoBase64!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                alignment: Alignment.center,
                color: couleurFond,
                child: const Text("Impossible d'afficher la photo"),
              ),
            ),
          )
        else
          Container(
            height: 220,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: couleurFond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                const Text('Ajoutez une photo du problème'),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _envoiEnCours
                    ? null
                    : () => _choisirPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Caméra'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _envoiEnCours
                    ? null
                    : () => _choisirPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}