import 'package:flutter/material.dart';

/// Constantes partagées par toute l'équipe.
/// Les valeurs techniques (clés des Map) correspondent EXACTEMENT à ce qui est
/// stocké dans Firestore : ne pas les modifier sans prévenir l'équipe.

// ---------------------------------------------------------------------------
// Firestore : noms des collections
// ---------------------------------------------------------------------------
const String kCollectionUsers = 'users';
const String kCollectionSignalements = 'signalements';

// ---------------------------------------------------------------------------
// Rôles utilisateurs
// ---------------------------------------------------------------------------
const String kRoleCitoyen = 'citoyen';
const String kRoleAdmin = 'admin';

// ---------------------------------------------------------------------------
// Catégories de signalement : valeur Firestore -> libellé affiché
// ---------------------------------------------------------------------------
const Map<String, String> kCategories = {
  'ordures': 'Dépôt d\'ordures',
  'caniveau': 'Caniveau bouché',
  'eau_stagnante': 'Eau stagnante',
  'autre': 'Autre',
};

const Map<String, IconData> kCategorieIcones = {
  'ordures': Icons.delete_outline,
  'caniveau': Icons.water_damage_outlined,
  'eau_stagnante': Icons.water_drop_outlined,
  'autre': Icons.help_outline,
};

// ---------------------------------------------------------------------------
// Niveaux d'urgence
// ---------------------------------------------------------------------------
const Map<String, String> kUrgences = {
  'faible': 'Urgence faible',
  'moyenne': 'Urgence moyenne',
  'elevee': 'Urgence élevée',
};

const Map<String, Color> kUrgenceCouleurs = {
  'faible': Color(0xFF43A047), // vert
  'moyenne': Color(0xFFFB8C00), // orange
  'elevee': Color(0xFFE53935), // rouge
};

// ---------------------------------------------------------------------------
// Statuts d'un signalement
// ---------------------------------------------------------------------------
const String kStatutEnAttente = 'en_attente';
const String kStatutEnCours = 'en_cours';
const String kStatutResolu = 'resolu';

const Map<String, String> kStatuts = {
  kStatutEnAttente: 'En attente',
  kStatutEnCours: 'En cours',
  kStatutResolu: 'Résolu',
};

const Map<String, Color> kStatutCouleurs = {
  kStatutEnAttente: Color(0xFF757575), // gris
  kStatutEnCours: Color(0xFF1E88E5), // bleu
  kStatutResolu: Color(0xFF2E7D32), // vert
};

// ---------------------------------------------------------------------------
// Communes d'Abidjan (saisie manuelle si le GPS est indisponible)
// ---------------------------------------------------------------------------
const List<String> kCommunes = [
  'Abobo',
  'Adjamé',
  'Attécoubé',
  'Cocody',
  'Koumassi',
  'Marcory',
  'Plateau',
  'Port-Bouët',
  'Treichville',
  'Yopougon',
  'Bingerville',
  'Songon',
  'Anyama',
];

// ---------------------------------------------------------------------------
// Photos (stockées en base64 dans Firestore, voir CLAUDE.md section 5)
// ---------------------------------------------------------------------------
const double kPhotoMaxDimension = 800;
const int kPhotoQualite = 60;
// Recompression si la première tentative est trop lourde
const double kPhotoMaxDimensionReduite = 600;
const int kPhotoQualiteReduite = 45;
// Au-delà, on recompresse (la limite d'un document Firestore est 1 Mo)
const int kPhotoBase64MaxLength = 700000;

// ---------------------------------------------------------------------------
// Rodium AI (analyse des photos)
// ---------------------------------------------------------------------------
const String kRodiumBaseUrl = 'https://api.rodiumai.io/v1';

// Modèle "vision" utilisé pour l'analyse. À confirmer par Dev 5 (feature/ia)
// avec GET /v1/models avant d'écrire ia_service.dart.
const String kRodiumModele = 'openai/gpt-4o-mini';

const Duration kRodiumTimeout = Duration(seconds: 20);

// La clé n'est JAMAIS écrite dans le code : elle est injectée au build avec
// --dart-define-from-file=dart_defines.json (fichier ignoré par git).
// Si elle est vide, l'application fonctionne simplement sans IA.
const String kRodiumApiKey = String.fromEnvironment('RODIUM_API_KEY');

// ---------------------------------------------------------------------------
// Helpers d'affichage : renvoient un libellé / une couleur même si la valeur
// en base est inattendue (évite un crash sur une donnée mal formée).
// ---------------------------------------------------------------------------
String libelleCategorie(String valeur) => kCategories[valeur] ?? 'Autre';
String libelleUrgence(String valeur) => kUrgences[valeur] ?? valeur;
String libelleStatut(String valeur) => kStatuts[valeur] ?? valeur;
Color couleurUrgence(String valeur) => kUrgenceCouleurs[valeur] ?? Colors.grey;
Color couleurStatut(String valeur) => kStatutCouleurs[valeur] ?? Colors.grey;
