import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/signalement_service.dart';
import '../models/signalement.dart';
import '../providers/auth_provider.dart';
import 'detail_screen.dart';

class MesSignalementsScreen extends StatelessWidget {
  const MesSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Signalements')),
        body: const Center(child: Text('Veuillez vous connecter pour voir vos signalements.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Signalements')),
      body: StreamBuilder<List<Signalement>>(
        stream: SignalementService().getMesSignalements(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mesSignalements = snapshot.data ?? [];
          if (mesSignalements.isEmpty) {
            return const Center(child: Text('Vous n\'avez encore créé aucun signalement.'));
          }

          return ListView.builder(
            itemCount: mesSignalements.length,
            itemBuilder: (context, index) {
              final item = mesSignalements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(item.categorie.toUpperCase()),
                  subtitle: Text('${item.commune} • ${item.statut.replaceAll('_', ' ')}'),
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
    );
  }
}