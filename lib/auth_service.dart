import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'user.dart';

class AuthService {
  static AppUser? currentUser;

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id != null) {
      currentUser = await DatabaseHelper.instance.getUserById(id);
    }
  }

  /// Return null jika sukses, atau pesan error.
  static Future<String?> register(
      String name, String email, String password) async {
    if (await DatabaseHelper.instance.emailExists(email)) {
      return 'Email sudah terdaftar';
    }
    await DatabaseHelper.instance.insertUser(name, email, password);
    return null;
  }

  static Future<bool> login(String email, String password) async {
    final u = await DatabaseHelper.instance.login(email, password);
    if (u == null) return false;
    currentUser = u;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', u.id);
    return true;
  }

  static Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
