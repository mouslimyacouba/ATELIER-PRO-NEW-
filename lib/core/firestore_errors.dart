import 'package:cloud_firestore/cloud_firestore.dart';

/// Traduit les erreurs Firestore/Firebase les plus courantes en messages
/// compréhensibles pour l'utilisateur, plutôt que d'afficher le message
/// technique brut (ex: "[cloud_firestore/permission-denied] Missing or
/// insufficient permissions."). Utilisé dans tous les providers.
String friendlyFirestoreError(Object e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return "Accès refusé — vérifie que tu es bien connecté, ou contacte le support si ça persiste.";
      case 'unavailable':
        return "Connexion instable — vérifie ta connexion internet et réessaie.";
      case 'not-found':
        return "Cet élément n'existe plus (peut-être déjà supprimé).";
      case 'already-exists':
        return "Cet élément existe déjà.";
      case 'resource-exhausted':
        return "Trop de requêtes en même temps — réessaie dans un instant.";
      case 'cancelled':
        return "Action annulée.";
      case 'deadline-exceeded':
        return "La requête a pris trop de temps — vérifie ta connexion et réessaie.";
      case 'failed-precondition':
        // Cas le plus fréquent : index Firestore composite manquant. On
        // garde le message technique (contient le lien direct pour créer
        // l'index) car c'est la seule façon de le voir en dehors d'un
        // terminal de développement (ex: app testée via un APK installé).
        return "Configuration base de données incomplète : ${e.message ?? 'index manquant'}";
      default:
        return e.message ?? "Une erreur est survenue (${e.code}).";
    }
  }
  return e.toString();
}
