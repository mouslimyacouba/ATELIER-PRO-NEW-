import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _ownerUid = 'atelier-owner';
const _otherUid = 'other-workshop';

bool _isOwner(String authUid, String documentOwnerUid) =>
    authUid == documentOwnerUid;

String _readRules(String path) => File(path).readAsStringSync();

void main() {
  group('Firestore security rules contract', () {
    late String rootRules;
    late String firebaseRules;

    setUpAll(() {
      rootRules = _readRules('firestore.rules');
      firebaseRules = _readRules('firebase/firestore.rules');
    });

    test('the deployable and documented rule files stay synchronized', () {
      expect(firebaseRules, rootRules);
    });

    test('stock uses owner checks for every operation', () {
      expect(rootRules, contains('match /stock/{docId}'));
      expect(
        rootRules,
        contains('allow read, delete: if isOwner(resource.data);'),
      );
      expect(
        rootRules,
        contains(
          'allow update: if isOwner(resource.data) && '
          'isOwner(request.resource.data);',
        ),
      );
      expect(
        rootRules,
        contains('allow create: if isOwner(request.resource.data);'),
      );
      expect(rootRules,
          isNot(contains('allow read, write: if request.auth != null;')));
    });

    test('owner and non-owner access cases are explicit', () {
      expect(_isOwner(_ownerUid, _ownerUid), isTrue);
      expect(_isOwner(_otherUid, _ownerUid), isFalse);
      expect(_isOwner('', _ownerUid), isFalse);
    });

    test('all user-owned Firestore collections keep the same policy', () {
      for (final collection in [
        'clients',
        'commandes',
        'paiements',
        'fiches',
        'modeles',
        'stock',
        'historique_modifications',
      ]) {
        expect(rootRules, contains('match /$collection/{docId}'));
        expect(rootRules,
            contains('allow read, delete: if isOwner(resource.data);'));
        expect(rootRules,
            contains('allow create: if isOwner(request.resource.data);'));
      }
    });
  });

  group('Storage security rules contract', () {
    late String rootRules;
    late String firebaseRules;

    setUpAll(() {
      rootRules = _readRules('storage.rules');
      firebaseRules = _readRules('firebase/storage.rules');
    });

    test('the deployable and documented rule files stay synchronized', () {
      expect(firebaseRules, rootRules);
    });

    test('logos stay public while workshop data stays owner-only', () {
      expect(rootRules, contains('match /logos/{userId}/{fileName}'));
      expect(rootRules, contains('allow read: if true; // logos publics'));

      for (final folder in ['photos', 'commandes', 'modeles_etapes']) {
        expect(rootRules, contains('match /$folder/{userId}/{fileName}'));
        expect(rootRules, contains('allow read: if isOwner(userId);'));
        expect(
          rootRules,
          contains(
              'allow create, update: if isOwner(userId) && isValidUpload();'),
        );
        expect(rootRules, contains('allow delete: if isOwner(userId);'));
      }
    });
  });
}
