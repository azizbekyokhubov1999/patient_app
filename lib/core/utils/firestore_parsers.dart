/// Safe parsing helpers for Firestore document fields with inconsistent types.
abstract final class FirestoreParsers {
  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static num? asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return num.tryParse(trimmed) ?? double.tryParse(trimmed);
    }
    return null;
  }

  static int asInt(dynamic value) => asNum(value)?.toInt() ?? 0;

  static double asDouble(dynamic value) => asNum(value)?.toDouble() ?? 0.0;

  static bool asBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == 'true' || lower == '1';
    }
    if (value is num) return value != 0;
    return false;
  }

  static List<String> asStringList(dynamic value) {
    if (value is! List) return const [];
    return List<String>.from(
      value.map((item) => item?.toString() ?? ''),
    );
  }
}
