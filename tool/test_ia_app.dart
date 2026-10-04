import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cleancity/services/ia_service.dart';
import 'package:cleancity/utils/constants.dart';

void main() {
  runApp(const TestIaApp());
}

class TestIaApp extends StatelessWidget {
  const TestIaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestIaScreen(),
    );
  }
}

class TestIaScreen extends StatefulWidget {
  const TestIaScreen({super.key});

  @override
  State<TestIaScreen> createState() => _TestIaScreenState();
}

class _TestIaScreenState extends State<TestIaScreen> {
  String resultat = 'Chargement de l’image...';

  @override
  void initState() {
    super.initState();
    _analyser();
  }

  Future<void> _analyser() async {
    try {
      // Vérifie que la clé Rodium a bien été injectée
      // avec --dart-define-from-file=dart_defines.json.
      if (kRodiumApiKey.isEmpty) {
        setState(() {
          resultat = 'ERREUR : clé Rodium non injectée.';
        });
        return;
      }

      // Charge l'image depuis les assets Flutter.
      final bytes = await rootBundle.load(
        'test/garbage_test_reduced.jpeg',
      );

      // Convertit l'image en Base64.
      final photoBase64 = base64Encode(
        bytes.buffer.asUint8List(),
      );

      if (!mounted) return;

      setState(() {
        resultat =
            'Image chargée (${photoBase64.length} caractères base64). '
            'Analyse en cours...';
      });

      // Appel du service Rodium AI.
      final service = IaService();
      final analyse = await service.analyserPhoto(photoBase64);

      if (!mounted) return;

      setState(() {
        resultat = analyse == null
            ? 'Aucun résultat : analyse échouée.'
            : jsonEncode(analyse);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resultat = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(resultat),
        ),
      ),
    );
  }
}
