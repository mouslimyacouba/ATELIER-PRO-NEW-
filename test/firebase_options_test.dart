import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atelierpro_mobile/firebase_options.dart';

void main() {
  setUp(dotenv.testLoad);
  tearDown(dotenv.clean);

  test('refuse de créer des options Firebase avec une configuration absente', () {
    expect(
      () => DefaultFirebaseOptions.web,
      throwsA(anything),
    );
  });
}