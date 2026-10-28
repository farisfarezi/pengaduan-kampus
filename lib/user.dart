  import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String p) => sha256.convert(utf8.encode(p)).toString();

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // 'mahasiswa' atau 'admin'

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
        role: m['role'] as String,
      );
}
