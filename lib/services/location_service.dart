import 'package:geolocator/geolocator.dart';

/// Service de géolocalisation : récupère la position GPS de l'utilisateur.
/// Ne lève jamais d'exception : si le service est désactivé ou la
/// permission refusée, renvoie simplement `null`. L'écran doit alors
/// proposer la saisie manuelle (commune + repère).
class LocationService {
  Future<Position?> obtenirPosition() async {
    try {
      final serviceActif = await Geolocator.isLocationServiceEnabled();
      if (!serviceActif) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Timeout, service coupé pendant la lecture, etc. : on retombe sur
      // la saisie manuelle plutôt que de planter l'écran.
      return null;
    }
  }
}
