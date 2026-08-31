import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Generates and persists a random guest ID on first launch, then reuses
/// it forever (until the app's local storage is cleared). Swap this out
/// for FirebaseAuth.instance.currentUser!.uid later if you add auth —
/// at that point you'll want a one-time migration that copies any
/// existing guest cart docs over to the authenticated user's cart.
class DeviceIdService {
  static const _key = 'guest_id';
  static String? _cachedId;

  static Future<String> getGuestId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }

    _cachedId = id;
    return id;
  }
}
