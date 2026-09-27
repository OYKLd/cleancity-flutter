import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/widgets/initials_avatar.dart';

void main() {
  test('InitialsAvatar.initials uses the first and last word', () {
    expect(InitialsAvatar.initials('Awa Koné'), 'AK');
    expect(InitialsAvatar.initials('  jean  paul dupont '), 'JD');
    expect(InitialsAvatar.initials('awa'), 'A');
    expect(InitialsAvatar.initials(''), '?');
    expect(InitialsAvatar.initials('   '), '?');
  });
}
