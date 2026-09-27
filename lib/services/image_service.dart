import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

/// Exception levée quand la photo reste trop lourde même après une seconde
/// compression : l'écran doit alors afficher un message d'erreur clair
/// (voir CLAUDE.md section 5, "contrôle obligatoire").
class ImageTropLourdeException implements Exception {
  const ImageTropLourdeException();

  @override
  String toString() =>
      'Cette photo est trop volumineuse, même après compression. '
      'Réessayez avec une autre photo.';
}

/// Service photo : sélection (caméra ou galerie) via image_picker,
/// compression et encodage en base64 (voir constantes kPhoto* dans
/// utils/constants.dart et CLAUDE.md section 5).
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Ouvre la caméra ou la galerie, compresse la photo et renvoie sa
  /// représentation base64 (prête pour le champ `photoBase64` de
  /// Firestore). Renvoie `null` si l'utilisateur annule la sélection.
  ///
  /// Si la chaîne obtenue dépasse [kPhotoBase64MaxLength] caractères
  /// (limite d'un document Firestore : 1 Mo), on redemande la photo avec
  /// une compression plus forte. Si elle est encore trop lourde, on lève
  /// [ImageTropLourdeException] pour que l'écran affiche une erreur.
  Future<String?> choisirPhoto(ImageSource source) async {
    final photo = await _picker.pickImage(
      source: source,
      maxWidth: kPhotoMaxDimension,
      maxHeight: kPhotoMaxDimension,
      imageQuality: kPhotoQualite,
    );
    if (photo == null) return null; // L'utilisateur a annulé.

    var base64 = await _encoderEnBase64(photo);
    if (base64.length <= kPhotoBase64MaxLength) return base64;

    // Photo trop lourde : on retente une compression plus forte.
    final photoReduite = await _picker.pickImage(
      source: source,
      maxWidth: kPhotoMaxDimensionReduite,
      maxHeight: kPhotoMaxDimensionReduite,
      imageQuality: kPhotoQualiteReduite,
    );
    if (photoReduite == null) return null;

    base64 = await _encoderEnBase64(photoReduite);
    if (base64.length > kPhotoBase64MaxLength) {
      throw const ImageTropLourdeException();
    }
    return base64;
  }

  Future<String> _encoderEnBase64(XFile fichier) async {
    final octets = await fichier.readAsBytes();
    return base64Encode(octets);
  }
}
