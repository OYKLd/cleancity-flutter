import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Service d'analyse de photo par Rodium AI.
class IaService {
  /// Analyse une photo et retourne les informations détectées par l'IA.
  ///
  /// Retourne null si :
  /// - la clé API n'est pas configurée ;
  /// - la requête échoue ;
  /// - le délai de 20 secondes est dépassé ;
  /// - la réponse de l'IA est invalide.
  Future<Map<String, String>?> analyserPhoto(String photoBase64) async {
    if (kRodiumApiKey.isEmpty) {
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$kRodiumBaseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $kRodiumApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': kRodiumModele,
              'max_tokens': 1024,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text': '''
Analyse cette photo d'un problème urbain.

Réponds uniquement avec un objet JSON valide au format :
{
  "categorie": "...",
  "urgence": "...",
  "description": "..."
}

categorie doit être l'une de :
ordures, caniveau, eau_stagnante, autre

urgence doit être l'une de :
faible, moyenne, elevee

La description doit être courte, en français, en une ou deux phrases.

Si aucun problème urbain identifiable n'est visible, utilise "autre".
''',
                    },
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$photoBase64',
                      },
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(kRodiumTimeout);

      // Diagnostic temporaire : affiche le code HTTP et la réponse
      // uniquement lorsqu'une erreur est renvoyée par Rodium.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('RODIUM HTTP ${response.statusCode}');
        print('RODIUM BODY: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body);

      final content = body['choices']?[0]?['message']?['content'];

      if (content is! String || content.trim().isEmpty) {
        print('RODIUM ERREUR : contenu de réponse vide ou invalide.');
        print('RODIUM BODY: ${response.body}');
        return null;
      }

      return _parserReponse(content);
    } catch (e) {
      // Diagnostic temporaire : affiche l'erreur réelle sans jamais
      // afficher la clé API.
      print('RODIUM EXCEPTION: $e');
      return null;
    }
  }

  Map<String, String>? _parserReponse(String content) {
    var texte = content.trim();

    // Retire les éventuelles balises Markdown ```json ... ```.
    if (texte.startsWith('```')) {
      texte = texte.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      texte = texte.replaceFirst(RegExp(r'\s*```$'), '');
    }

    try {
      final json = jsonDecode(texte);

      if (json is! Map) {
        print('RODIUM ERREUR : la réponse n\'est pas un objet JSON.');
        print('RODIUM CONTENT: $content');
        return null;
      }

      final categorie = json['categorie'];
      final urgence = json['urgence'];
      final description = json['description'];

      const categoriesAutorisees = {
        'ordures',
        'caniveau',
        'eau_stagnante',
        'autre',
      };

      const urgencesAutorisees = {
        'faible',
        'moyenne',
        'elevee',
      };

      if (categorie is! String ||
          urgence is! String ||
          description is! String ||
          !categoriesAutorisees.contains(categorie) ||
          !urgencesAutorisees.contains(urgence) ||
          description.trim().isEmpty) {
        print('RODIUM ERREUR : réponse JSON invalide.');
        print('RODIUM CONTENT: $content');
        return null;
      }

      return {
        'categorie': categorie,
        'urgence': urgence,
        'description': description.trim(),
      };
    } catch (e) {
      print('RODIUM ERREUR : impossible de parser le JSON.');
      print('RODIUM EXCEPTION: $e');
      print('RODIUM CONTENT: $content');
      return null;
    }
  }
}
