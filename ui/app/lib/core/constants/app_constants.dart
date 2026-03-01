/// Non-string constants: validation lengths, status values, defaults,
/// and network timeouts.  Import this instead of scattering magic values
/// across the widget tree and data layer.
class AppConstants {
  AppConstants._();

  // ── Validation ────────────────────────────────────────────────────────────
  static const int phoneNumberLength = 10;
  static const int pincodeLength = 6;

  /// Default pincode for nearby (clinics/shops) seed data — Kota 324008.
  static const String defaultSeedPincode = '324008';
  static const int orderIdDisplayLength = 8;
  static const int maxTextInputLength = 1000;

  // ── Order status values ───────────────────────────────────────────────────
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // ── Shop status values ────────────────────────────────────────────────────
  static const String shopStatusApproved = 'approved';
  static const String shopStatusPending = 'pending';

  // ── Message roles ─────────────────────────────────────────────────────────
  static const String roleUser = 'user';
  static const String roleAssistant = 'assistant';

  // ── Defaults ─────────────────────────────────────────────────────────────
  static const String defaultLanguage = 'hi';
  static const String defaultInventoryUnit = 'piece';
  static const String defaultAudioContentType = 'audio/m4a';

  // ── Network timeouts (seconds) ────────────────────────────────────────────
  static const int apiConnectTimeoutSeconds = 15;
  static const int apiReceiveTimeoutSeconds = 30;
  static const int s3UploadReceiveTimeoutSeconds = 120;

  // ── UI / formatting ───────────────────────────────────────────────────────
  static const String currencySymbol = '₹';
  static const String phoneCountryPrefix = '+91  ';
  static const String appIconAsset = 'assets/images/app_icon.png';

  // ── Supported languages (code → native name → English label) ─────────────
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'hi', 'name': 'हिंदी', 'label': 'Hindi'},
    {'code': 'en', 'name': 'English', 'label': 'English'},
    {'code': 'mr', 'name': 'मराठी', 'label': 'Marathi'},
    {'code': 'ta', 'name': 'தமிழ்', 'label': 'Tamil'},
    {'code': 'te', 'name': 'తెలుగు', 'label': 'Telugu'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'label': 'Kannada'},
    {'code': 'bn', 'name': 'বাংলা', 'label': 'Bengali'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'label': 'Gujarati'},
  ];
}
