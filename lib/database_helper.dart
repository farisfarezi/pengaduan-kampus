import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'report.dart';
import 'user.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _db;

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'pengaduan.db');
    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async {
        await _createUsers(db);
        await db.execute('''
          CREATE TABLE reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            photo_path TEXT,
            latitude REAL,
            longitude REAL,
            location_note TEXT,
            status TEXT NOT NULL DEFAULT 'Menunggu',
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
          )''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await _createUsers(db);
          await db.execute('ALTER TABLE reports ADD COLUMN user_id INTEGER');
        }
      },
    );
  }

  Future<void> _createUsers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'mahasiswa'
      )''');
    // Akun admin bawaan (dicek terlebih dahulu jika sudah ada)
    final existingAdmin = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@kampus.id'],
      limit: 1,
    );
    if (existingAdmin.isEmpty) {
      await db.insert('users', {
        'name': 'Admin Kampus',
        'email': 'admin@kampus.id',
        'password': hashPassword('admin123'),
        'role': 'admin',
      });
    }
  }

  // ---------- USERS ----------
  Future<bool> emailExists(String email) async {
    final r = await (await db).query('users',
        where: 'email = ?', whereArgs: [email.trim().toLowerCase()], limit: 1);
    return r.isNotEmpty;
  }

  Future<void> insertUser(String name, String email, String password) async {
    await (await db).insert('users', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': hashPassword(password),
      'role': 'mahasiswa',
    });
  }

  Future<AppUser?> login(String email, String password) async {
    final r = await (await db).query('users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim().toLowerCase(), hashPassword(password)],
        limit: 1);
    return r.isEmpty ? null : AppUser.fromMap(r.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final r = await (await db)
        .query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isEmpty ? null : AppUser.fromMap(r.first);
  }

  // ---------- REPORTS ----------
  Future<int> insert(Report r) async =>
      (await db).insert('reports', r.toMap()..remove('id'));

  /// userId null = semua laporan (untuk admin)
  Future<List<Report>> getAll({String? status, int? userId}) async {
    final where = <String>[];
    final args = <Object>[];
    if (status != null) {
      where.add('r.status = ?');
      args.add(status);
    }
    if (userId != null) {
      where.add('r.user_id = ?');
      args.add(userId);
    }
    final w = where.isEmpty ? '' : 'WHERE ${where.join(" AND ")}';
    final rows = await (await db).rawQuery(
      'SELECT r.*, u.name AS user_name FROM reports r '
      'LEFT JOIN users u ON u.id = r.user_id $w '
      'ORDER BY r.created_at DESC',
      args.isEmpty ? null : args,
    );
    return rows.map(Report.fromMap).toList();
  }

  Future<void> updateStatus(int id, String status) async => (await db)
      .update('reports', {'status': status}, where: 'id = ?', whereArgs: [id]);

  Future<void> delete(int id) async =>
      (await db).delete('reports', where: 'id = ?', whereArgs: [id]);
}
