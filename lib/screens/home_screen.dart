import 'package:flutter/material.dart';
import '../services/signalement_service.dart';
import '../models/signalement.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SignalementService _signalementService = SignalementService();
  String _selectedStatut = 'tous';
  String _selectedCategorie = 'toutes';

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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatut,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tous', child: Text('Tous statuts')),
                      DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                      DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                      DropdownMenuItem(value: 'resolu', child: Text('Résolu')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatut = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'toutes', child: Text('Toutes catégories')),
                      DropdownMenuItem(value: 'ordures', child: Text('Ordures')),
                      DropdownMenuItem(value: 'caniveau', child: Text('Caniveau')),
                      DropdownMenuItem(value: 'eau_stagnante', child: Text('Eau stagnante')),
                      DropdownMenuItem(value: 'autre', child: Text('Autre')),
                    ],
                    onChanged: (val) => setState(() => _selectedCategorie = val!),
                  ),
                ),
              ],
            ),
          ),

          // Stream en temps réel
          Expanded(
            child: StreamBuilder<List<Signalement>>(
              stream: _signalementService.getSignalements(
                statut: _selectedStatut,
                categorie: _selectedCategorie,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final signalements = snapshot.data ?? [];
                if (signalements.isEmpty) {
                  return const Center(child: Text('Aucun signalement trouvé.'));
                }

                return ListView.builder(
                  itemCount: signalements.length,
                  itemBuilder: (context, index) {
                    final item = signalements[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(item.categorie.toUpperCase()),
                        subtitle: Text('${item.commune} • ${item.statut}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(signalement: item),
                            ),
                          );
                        },
                      ),
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