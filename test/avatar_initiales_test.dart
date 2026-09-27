import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/widgets/avatar_initiales.dart';

void main() {
  test('AvatarInitiales.initiales prend la première et la dernière lettre', () {
    expect(AvatarInitiales.initiales('Awa Koné'), 'AK');
    expect(AvatarInitiales.initiales('  jean  paul dupont '), 'JD');
    expect(AvatarInitiales.initiales('awa'), 'A');
    expect(AvatarInitiales.initiales(''), '?');
    expect(AvatarInitiales.initiales('   '), '?');
  });
}
