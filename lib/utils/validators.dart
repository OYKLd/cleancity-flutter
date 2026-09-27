/// Form validators shared by the auth and profile screens.
/// Each one returns null when the value is valid, or a French message.
class Validators {
  Validators._();

  /// Minimum enforced by Firebase Auth for email/password accounts.
  static const int minPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? notEmpty(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Veuillez saisir votre nom.';
    if (text.length < 2) return 'Le nom doit contenir au moins 2 caractères.';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Veuillez saisir votre adresse email.';
    if (!_emailPattern.hasMatch(text)) return 'Adresse email invalide.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Veuillez saisir un mot de passe.';
    if (text.length < minPasswordLength) {
      return 'Le mot de passe doit contenir au moins '
          '$minPasswordLength caractères.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final text = value ?? '';
    if (text.isEmpty) return 'Veuillez confirmer le mot de passe.';
    if (text != original) return 'Les mots de passe ne correspondent pas.';
    return null;
  }
}
