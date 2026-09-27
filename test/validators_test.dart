import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a valid address, even with surrounding spaces', () {
      expect(Validators.email('awa.kone@exemple.com'), isNull);
      expect(Validators.email('  awa.kone@exemple.ci '), isNull);
    });

    test('rejects an empty or malformed address', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('   '), isNotNull);
      expect(Validators.email('awa@exemple'), isNotNull);
      expect(Validators.email('awa exemple.com'), isNotNull);
      expect(Validators.email('@exemple.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires at least ${Validators.minPasswordLength} characters', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('flags an empty or different confirmation', () {
      expect(Validators.confirmPassword('', 'secret1'), isNotNull);
      expect(Validators.confirmPassword('secret2', 'secret1'), isNotNull);
      expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });

  group('Validators.name', () {
    test('requires a name of at least 2 characters', () {
      expect(Validators.name(null), isNotNull);
      expect(Validators.name(' '), isNotNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('Awa Koné'), isNull);
    });
  });

  group('Validators.notEmpty', () {
    test('returns the given message when the value is blank', () {
      expect(Validators.notEmpty('', 'Obligatoire'), 'Obligatoire');
      expect(Validators.notEmpty('ok', 'Obligatoire'), isNull);
    });
  });
}
