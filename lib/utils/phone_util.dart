/// Normalizes phone numbers for matching device contacts with Firestore users.
class PhoneUtil {
  /// Keeps digits only. For Indian numbers, returns the last 10 digits.
  static String normalize(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String toIndiaE164(String phone) {
    final last10 = normalize(phone);
    if (last10.length != 10) return phone;
    return '+91$last10';
  }

  static bool isValidIndianMobile(String phone) {
    return normalize(phone).length == 10;
  }
}
