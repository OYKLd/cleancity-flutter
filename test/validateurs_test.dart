import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/utils/validateurs.dart';

void main() {
  group('Validateurs.email', () {
    test('accepte une adresse valide, même entourée d\'espaces', () {
      expect(Validateurs.email('awa.kone@exemple.com'), isNull);
      expect(Validateurs.email('  awa.kone@exemple.ci '), isNull);
    });

    test('refuse une adresse vide ou mal formée', () {
      expect(Validateurs.email(null), isNotNull);
      expect(Validateurs.email('   '), isNotNull);
      expect(Validateurs.email('awa@exemple'), isNotNull);
      expect(Validateurs.email('awa exemple.com'), isNotNull);
      expect(Validateurs.email('@exemple.com'), isNotNull);
    });
  });

  group('Validateurs.motDePasse', () {
    test('exige au moins ${Validateurs.longueurMinMotDePasse} caractères', () {
      expect(Validateurs.motDePasse(''), isNotNull);
      expect(Validateurs.motDePasse('12345'), isNotNull);
      expect(Validateurs.motDePasse('123456'), isNull);
    });
  });

  group('Validateurs.confirmationMotDePasse', () {
    test('signale une confirmation vide ou différente', () {
      expect(Validateurs.confirmationMotDePasse('', 'secret1'), isNotNull);
      expect(
        Validateurs.confirmationMotDePasse('secret2', 'secret1'),
        isNotNull,
      );
      expect(Validateurs.confirmationMotDePasse('secret1', 'secret1'), isNull);
    });
  });

  group('Validateurs.nom', () {
    test('exige un nom d\'au moins 2 caractères', () {
      expect(Validateurs.nom(null), isNotNull);
      expect(Validateurs.nom(' '), isNotNull);
      expect(Validateurs.nom('A'), isNotNull);
      expect(Validateurs.nom('Awa Koné'), isNull);
    });
  });

  group('Validateurs.requis', () {
    test('renvoie le message fourni quand la valeur est vide', () {
      expect(Validateurs.requis('', 'Obligatoire'), 'Obligatoire');
      expect(Validateurs.requis('ok', 'Obligatoire'), isNull);
    });
  });
}
