import 'package:flutter/material.dart';
import '../../models/signalement.dart';
import '../../services/signalement_service.dart';
import '../../utils/constants.dart';
import '../../widgets/signalement_card.dart';
import '../signalement/detail_signalement_screen.dart';

/// Onglet « Accueil » : fil des signalements en temps réel avec filtres.
class FilSignalementsScreen extends StatefulWidget {
  const FilSignalementsScreen({super.key});

  @override
  State<FilSignalementsScreen> createState() => _FilSignalementsScreenState();
}

class _FilSignalementsScreenState extends State<FilSignalementsScreen> {
  final SignalementService _signalementService = SignalementService();
  String? _selectedStatut;
  String? _selectedCategorie;

  /// Helper pour convertir kStatuts / kCategories en liste de DropdownMenuItem
  List<DropdownMenuItem<String?>> _buildDropdownItems(
    dynamic constantsMapOrList,
  ) {
    if (constantsMapOrList is Map<String, String>) {
      return constantsMapOrList.entries.map((entry) {
        return DropdownMenuItem<String?>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList();
    } else if (constantsMapOrList is List<String>) {
      return constantsMapOrList.map((item) {
        return DropdownMenuItem<String?>(
          value: item,
          child: Text(libelleStatut(item)),
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CleanCity - Signalements'),
      ),
      body: Column(
        children: [
          // Section Filtres
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Filtre par Statut
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedStatut,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous statuts'),
                      ),
                      ..._buildDropdownItems(kStatuts),
                    ],
                    onChanged: (val) => setState(() => _selectedStatut = val),
                  ),
                ),
                const SizedBox(width: 8),
                // Filtre par Catégorie
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Toutes catégories'),
                      ),
                      ..._buildDropdownItems(kCategories),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedCategorie = val),
                  ),
                ),
              ],
            ),
          ),

          // Stream des signalements en temps réel
          Expanded(
            child: StreamBuilder<List<Signalement>>(
              stream: _signalementService.getSignalements(
                statut: _selectedStatut,
                categorie: _selectedCategorie,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Une erreur est survenue lors du chargement des signalements.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final signalements = snapshot.data ?? [];
                if (signalements.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun signalement ne correspond à vos critères.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: signalements.length,
                  itemBuilder: (context, index) {
                    final item = signalements[index];

                    return SignalementCard(
                      signalement: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailSignalementScreen(
                              signalement: item,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
