/// FCM configuration for client-side push (learning / dev only).
///
/// ## Setup (no Cloud Functions, no legacy server key)
///
/// 1. Open [Firebase Console](https://console.firebase.google.com) → your project
/// 2. Project Settings → **Service accounts** → **Generate new private key**
/// 3. Save the downloaded JSON as `assets/fcm_service_account.json`
/// 4. Run `flutter pub get` and rebuild the app
///
/// 5. In [Google Cloud Console](https://console.cloud.google.com):
///    APIs & Services → Library → enable **Firebase Cloud Messaging API**
///
/// ## Optional legacy fallback
///
/// If your project still has a legacy server key (Cloud Messaging tab),
/// paste it in [legacyServerKey]. HTTP v1 is tried first.
///
/// WARNING: Never ship service account credentials or server keys in a
/// production app. Use a backend or Cloud Functions for real apps.
class FcmConfig {
  static const String projectId = 'chatmate-4adc0';

  /// Path to the service account JSON inside `pubspec.yaml` assets.
  static const String serviceAccountAssetPath =
      'assets/fcm_service_account.json';

  /// Leave empty unless you have the legacy FCM server key.
  static const String legacyServerKey = '';
}
