import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/signalement.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';
import '../../services/signalement_service.dart';
import '../../utils/constants.dart';

/// Écran de création d'un signalement.
///
/// Permet à l'utilisateur d'ajouter :
/// - une photo ;
/// - une catégorie ;
/// - un niveau d'urgence ;
/// - une description ;
/// - une localisation GPS ou manuelle.
class NouveauSignalementScreen extends StatefulWidget {
  const NouveauSignalementScreen({super.key});

  @override
  State<NouveauSignalementScreen> createState() =>
      _NouveauSignalementScreenState();
}

class _NouveauSignalementScreenState extends State<NouveauSignalementScreen> {
  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();
  final SignalementService _signalementService = SignalementService();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _repereController = TextEditingController();

  String? _photoBase64;
  String? _categorieChoisie;
  String? _urgenceChoisie;

  bool _envoiEnCours = false;

  // Localisation.
  Position? _position;
  bool _recherchePositionEnCours = false;
  bool _saisieManuelle = false;
  String? _communeChoisie;

  @override
  void dispose() {
    _descriptionController.dispose();
    _repereController.dispose();
    super.dispose();
  }

  /// Sélectionne une photo depuis la caméra ou la galerie.
  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      final base64 = await _imageService.choisirPhoto(source);

      if (base64 == null) {
        return;
      }

      setState(() {
        _photoBase64 = base64;
      });
    } catch (e) {
      _afficherErreur(e.toString());
    }
  }

  /// Récupère la position GPS de l'utilisateur.
  Future<void> _recupererPosition() async {
    setState(() {
      _recherchePositionEnCours = true;
    });

    final position = await _locationService.obtenirPosition();

    if (!mounted) {
      return;
    }

    setState(() {
      _recherchePositionEnCours = false;

      if (position != null) {
        _position = position;
        _saisieManuelle = false;
      } else {
        _position = null;
        _saisieManuelle = true;
      }
    });

    if (position == null) {
      _afficherErreur(
        'Position indisponible. Indique ta commune et un repère.',
      );
    }
  }

  /// Valide et envoie le signalement dans Firestore.
  Future<void> _envoyerSignalement() async {
    // Vérification de la photo.
    if (_photoBase64 == null) {
      _afficherErreur('Ajoutez une photo du problème.');
      return;
    }

    // Vérification de la catégorie.
    if (_categorieChoisie == null) {
      _afficherErreur('Choisissez une catégorie.');
      return;
    }

    // Vérification de l'urgence.
    if (_urgenceChoisie == null) {
      _afficherErreur("Choisissez un niveau d'urgence.");
      return;
    }

    // Vérification de la description.
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      _afficherErreur('Décrivez brièvement le problème.');
      return;
    }

    // Vérification de l'utilisateur connecté.
    final utilisateur = context.read<AuthProvider>().user;

    if (utilisateur == null) {
      _afficherErreur(
        'Vous devez être connecté pour signaler un problème.',
      );
      return;
    }

    setState(() {
      _envoiEnCours = true;
    });

    try {
      final signalement = Signalement(
        userId: utilisateur.uid,
        userNom: context.read<AuthProvider>().displayName,
        description: description,
        photoBase64: _photoBase64!,
        categorie: _categorieChoisie!,
        urgence: _urgenceChoisie!,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        commune: _saisieManuelle ? _communeChoisie : null,
        repere: _saisieManuelle && _repereController.text.trim().isNotEmpty
            ? _repereController.text.trim()
            : null,
      );

      await _signalementService.creerSignalement(signalement);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signalement envoyé, merci !'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _afficherErreur(
        'Impossible d\'envoyer le signalement. '
        'Vérifiez votre connexion et réessayez.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _envoiEnCours = false;
        });
      }
    }
  }

  /// Affiche un message d'erreur.
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau signalement'),
      ),
      body: AbsorbPointer(
        absorbing: _envoiEnCours,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _blocPhoto(context),
            const SizedBox(height: 24),

            // Catégorie.
            DropdownButtonFormField<String>(
              initialValue: _categorieChoisie,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
              ),
              items: kCategories.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: _envoiEnCours
                  ? null
                  : (valeur) {
                      setState(() {
                        _categorieChoisie = valeur;
                      });
                    },
            ),

            const SizedBox(height: 16),

            // Urgence.
            DropdownButtonFormField<String>(
              initialValue: _urgenceChoisie,
              decoration: const InputDecoration(
                labelText: 'Urgence',
              ),
              items: kUrgences.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: _envoiEnCours
                  ? null
                  : (valeur) {
                      setState(() {
                        _urgenceChoisie = valeur;
                      });
                    },
            ),

            const SizedBox(height: 16),

            // Description.
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

            // Localisation.
            _blocLocalisation(context),

            const SizedBox(height: 8),

            // Bouton d'envoi.
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

  /// Bloc permettant d'ajouter une photo.
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
              errorBuilder:
                  (
                    context,
                    error,
                    stackTrace,
                  ) => Container(
                    height: 220,
                    alignment: Alignment.center,
                    color: couleurFond,
                    child: const Text(
                      'Impossible d\'afficher la photo',
                    ),
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
                const Text(
                  'Ajoutez une photo du problème',
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        Row(
          children: [
            // Caméra.
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _envoiEnCours
                    ? null
                    : () => _choisirPhoto(
                        ImageSource.camera,
                      ),
                icon: const Icon(
                  Icons.camera_alt_outlined,
                ),
                label: const Text('Caméra'),
              ),
            ),

            const SizedBox(width: 12),

            // Galerie.
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _envoiEnCours
                    ? null
                    : () => _choisirPhoto(
                        ImageSource.gallery,
                      ),
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text('Galerie'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bloc de gestion de la localisation.
  Widget _blocLocalisation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Localisation (facultative)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_position != null && !_saisieManuelle) ...[
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Position GPS récupérée',
                  ),
                ),
                TextButton(
                  onPressed: _envoiEnCours
                      ? null
                      : () {
                          setState(() {
                            _saisieManuelle = true;
                          });
                        },
                  child: const Text(
                    'Saisir manuellement',
                  ),
                ),
              ],
            ),
          ] else ...[
            // GPS.
            OutlinedButton.icon(
              onPressed: (_envoiEnCours || _recherchePositionEnCours)
                  ? null
                  : _recupererPosition,
              icon: _recherchePositionEnCours
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                    ),
              label: Text(
                _recherchePositionEnCours
                    ? 'Recherche en cours...'
                    : 'Utiliser ma position GPS',
              ),
            ),

            const SizedBox(height: 12),

            // Commune.
            DropdownButtonFormField<String>(
              initialValue: _communeChoisie,
              decoration: const InputDecoration(
                labelText: 'Commune',
              ),
              items: kCommunes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: _envoiEnCours
                  ? null
                  : (valeur) {
                      setState(() {
                        _communeChoisie = valeur;
                        _saisieManuelle = true;
                      });
                    },
            ),

            const SizedBox(height: 12),

            // Repère.
            TextField(
              controller: _repereController,
              enabled: !_envoiEnCours,
              // Les règles Firestore refusent un repère de plus de 200 caractères.
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Repère (optionnel)',
                hintText: 'Ex. : près du marché, en face de la pharmacie...',
              ),
              onChanged: (_) {
                setState(() {
                  _saisieManuelle = true;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
