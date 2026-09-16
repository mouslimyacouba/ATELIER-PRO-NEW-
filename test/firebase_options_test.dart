import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atelierpro_mobile/firebase_options.dart';

void main() {
  setUp(dotenv.testLoad);
  tearDown(dotenv.clean);

  test('refuse de créer des options Firebase avec une configuration absente', () {
    expect(
      () => DefaultFirebaseOptions.web,
      throwsA(
        isA<FirebaseConfigurationException>().having(
          (error) => error.missingVariables,
          'missingVariables',
          containsAll([
            'FIREBASE_WEB_API_KEY',
            'FIREBASE_WEB_APP_ID',
            'FIREBASE_MESSAGING_SENDER_ID',
            'FIREBASE_PROJECT_ID',
            'FIREBASE_STORAGE_BUCKET',
          ]),
        ),
      ),
    );
  });
}