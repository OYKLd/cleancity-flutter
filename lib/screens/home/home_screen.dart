import 'package:flutter/material.dart';

import '../profil/profil_screen.dart';
import '../signalement/mes_signalements_screen.dart';
import '../signalement/nouveau_signalement_screen.dart';
import 'fil_signalements_screen.dart';

/// Écran principal une fois connecté : barre de navigation en bas avec
/// trois onglets (Accueil, Mes signalements, Profil).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _ongletActif = 0;

  // IndexedStack garde les onglets en mémoire : on ne perd pas la position
  // de défilement ni les filtres en changeant d'onglet.
  static const List<Widget> _onglets = [
    FilSignalementsScreen(),
    MesSignalementsScreen(),
    ProfilScreen(),
  ];

  void _ouvrirNouveauSignalement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NouveauSignalementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _ongletActif, children: _onglets),
      // Le bouton « Signaler » n'apparaît que sur l'onglet Accueil
      floatingActionButton: _ongletActif == 0
          ? FloatingActionButton.extended(
              onPressed: _ouvrirNouveauSignalement,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Signaler'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _ongletActif,
        onDestinationSelected: (index) => setState(() => _ongletActif = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Mes signalements',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
