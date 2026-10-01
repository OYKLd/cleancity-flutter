import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/signalement.dart';
import '../../providers/auth_provider.dart';
import '../../services/signalement_service.dart';
import '../../widgets/signalement_card.dart';
import 'detail_signalement_screen.dart';

class MesSignalementsScreen extends StatelessWidget {
  const MesSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Signalements')),
        body: const Center(
          child: Text('Veuillez vous connecter pour voir vos signalements.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Signalements')),
      body: StreamBuilder<List<Signalement>>(
        stream: SignalementService().getMesSignalements(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur lors du chargement de vos signalements.'),
            );
          }

          final mesSignalements = snapshot.data ?? [];
          if (mesSignalements.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez encore créé aucun signalement.'),
            );
          }

          return ListView.builder(
            itemCount: mesSignalements.length,
            itemBuilder: (context, index) {
              final item = mesSignalements[index];

              return SignalementCard(
                signalement: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailSignalementScreen(signalement: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
