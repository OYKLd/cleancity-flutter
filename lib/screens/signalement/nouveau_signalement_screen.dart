import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ia_service.dart';
import '../../widgets/ia_result_widgets.dart';

/// Création d'un signalement avec analyse automatique par Rodium AI.
class NouveauSignalementScreen extends StatefulWidget {
  const NouveauSignalementScreen({super.key});

  @override
  State<NouveauSignalementScreen> createState() =>
      _NouveauSignalementScreenState();
}

class _NouveauSignalementScreenState extends State<NouveauSignalementScreen> {
  final ImagePicker _picker = ImagePicker();
  final IaService _iaService = IaService();

  File? _photo;

  bool _isLoading = false;
  String? _erreur;

  String? _categorie;
  String? _urgence;
  String? _description;

  /// Sélectionne une photo depuis la galerie.
  Future<void> _choisirPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _photo = File(image.path);
        _erreur = null;
        _categorie = null;
        _urgence = null;
        _description = null;
      });

      await _analyser();
    } catch (e) {
      setState(() {
        _erreur = 'Impossible de sélectionner la photo.';
      });
    }
  }

  /// Analyse la photo avec Rodium AI.
  Future<void> _analyser() async {
    if (_photo == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _erreur = null;
      _categorie = null;
      _urgence = null;
      _description = null;
    });

    try {
      final bytes = await _photo!.readAsBytes();
      final photoBase64 = base64Encode(bytes);

      final resultat = await _iaService.analyserPhoto(photoBase64);

      if (!mounted) {
        return;
      }

      if (resultat == null) {
        setState(() {
          _isLoading = false;
          _erreur =
              'L’analyse n’a pas pu être effectuée. '
              'Vérifiez votre connexion puis réessayez.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _categorie = resultat['categorie'];
        _urgence = resultat['urgence'];
        _description = resultat['description'];
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _erreur = 'Une erreur est survenue pendant l’analyse de la photo.';
      });
    }
  }

  IconData _iconeCategorie(String? categorie) {
    switch (categorie) {
      case 'ordures':
        return Icons.delete_outline_rounded;
      case 'caniveau':
        return Icons.water_damage_outlined;
      case 'eau_stagnante':
        return Icons.water_drop_outlined;
      default:
        return Icons.location_city_outlined;
    }
  }

  String _libelleCategorie(String? categorie) {
    switch (categorie) {
      case 'ordures':
        return 'Ordures';
      case 'caniveau':
        return 'Caniveau';
      case 'eau_stagnante':
        return 'Eau stagnante';
      case 'autre':
        return 'Autre';
      default:
        return 'Non déterminée';
    }
  }

  IconData _iconeUrgence(String? urgence) {
    switch (urgence) {
      case 'faible':
        return Icons.check_circle_outline_rounded;
      case 'moyenne':
        return Icons.warning_amber_rounded;
      case 'elevee':
        return Icons.priority_high_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _libelleUrgence(String? urgence) {
    switch (urgence) {
      case 'faible':
        return 'Faible';
      case 'moyenne':
        return 'Moyenne';
      case 'elevee':
        return 'Élevée';
      default:
        return 'Non déterminée';
    }
  }

  Color _couleurUrgence(String? urgence) {
    switch (urgence) {
      case 'faible':
        return const Color(0xFF16A34A);
      case 'moyenne':
        return const Color(0xFFD97706);
      case 'elevee':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  Color _fondUrgence(String? urgence) {
    switch (urgence) {
      case 'faible':
        return const Color(0xFFE8F5E9);
      case 'moyenne':
        return const Color(0xFFFEF3C7);
      case 'elevee':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyseTerminee =
        !_isLoading &&
        _erreur == null &&
        _categorie != null &&
        _description != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau signalement'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_photo == null) ...[
                const Text(
                  'Signaler un problème',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prenez une photo du problème pour permettre à '
                  'l’intelligence artificielle de l’identifier.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _choisirPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Choisir une photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(
                        color: Color(0xFF16A34A),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],

              if (_photo != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(
                    _photo!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 24),

                if (_isLoading) const IaLoadingCard(),

                if (_erreur != null)
                  IaErrorCard(
                    message: _erreur!,
                    onRetry: _analyser,
                  ),

                if (analyseTerminee) ...[
                  const IaHeaderCard(),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: IaInfoCard(
                          icon: _iconeCategorie(_categorie),
                          title: 'Catégorie',
                          value: _libelleCategorie(_categorie),
                          iconColor: const Color(0xFF16A34A),
                          backgroundColor: const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: IaInfoCard(
                          icon: _iconeUrgence(_urgence),
                          title: 'Urgence',
                          value: _libelleUrgence(_urgence),
                          iconColor: _couleurUrgence(_urgence),
                          backgroundColor: _fondUrgence(_urgence),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  IaDescriptionCard(
                    description: _description!,
                  ),

                  const SizedBox(height: 16),

                  const IaInfoMessage(),

                  const SizedBox(height: 16),

                  IaRetryButton(
                    onPressed: _choisirPhoto,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
