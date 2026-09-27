/// Form validators shared by the auth and profile screens.
/// Each one returns null when the value is valid, or a French message.
class Validateurs {
  Validateurs._();

  /// Minimum enforced by Firebase Auth for email/password accounts.
  static const int longueurMinMotDePasse = 6;

  static final RegExp _formatEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? requis(String? valeur, String message) {
    if (valeur == null || valeur.trim().isEmpty) return message;
    return null;
  }

  static String? nom(String? valeur) {
    final texte = valeur?.trim() ?? '';
    if (texte.isEmpty) return 'Veuillez saisir votre nom.';
    if (texte.length < 2) return 'Le nom doit contenir au moins 2 caractères.';
    return null;
  }

  static String? email(String? valeur) {
    final texte = valeur?.trim() ?? '';
    if (texte.isEmpty) return 'Veuillez saisir votre adresse email.';
    if (!_formatEmail.hasMatch(texte)) return 'Adresse email invalide.';
    return null;
  }

  static String? motDePasse(String? valeur) {
    final texte = valeur ?? '';
    if (texte.isEmpty) return 'Veuillez saisir un mot de passe.';
    if (texte.length < longueurMinMotDePasse) {
      return 'Le mot de passe doit contenir au moins '
          '$longueurMinMotDePasse caractères.';
    }
    return null;
  }

  static String? confirmationMotDePasse(String? valeur, String original) {
    final texte = valeur ?? '';
    if (texte.isEmpty) return 'Veuillez confirmer le mot de passe.';
    if (texte != original) return 'Les mots de passe ne correspondent pas.';
    return null;
  }
}
