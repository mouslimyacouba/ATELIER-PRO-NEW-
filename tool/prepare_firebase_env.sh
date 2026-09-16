#!/usr/bin/env bash
set -euo pipefail

# Génère le fichier ignoré par Git consommé par flutter_dotenv.
# Les valeurs viennent des variables d'environnement Replit ou du shell local.
# Ne jamais afficher ce fichier dans les logs.
umask 077

printf '%s\n' \
  "FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID-}" \
  "FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET-}" \
  "FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID-}" \
  "FIREBASE_WEB_API_KEY=${FIREBASE_WEB_API_KEY-}" \
  "FIREBASE_WEB_APP_ID=${FIREBASE_WEB_APP_ID-}" \
  "FIREBASE_WEB_MEASUREMENT_ID=${FIREBASE_WEB_MEASUREMENT_ID-}" \
  "FIREBASE_ANDROID_API_KEY=${FIREBASE_ANDROID_API_KEY-}" \
  "FIREBASE_ANDROID_APP_ID=${FIREBASE_ANDROID_APP_ID-}" \
  "FIREBASE_IOS_API_KEY=${FIREBASE_IOS_API_KEY-}" \
  "FIREBASE_IOS_APP_ID=${FIREBASE_IOS_APP_ID-}" \
  > .env