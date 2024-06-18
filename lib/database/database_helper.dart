import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_db.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        date_reg TEXT NOT NULL,
        email TEXT NOT NULL,
        fullname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthdate TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE users ADD COLUMN lastname TEXT NOT NULL DEFAULT '';
      ''');
    }
  }

  Future<int> insertUser(
      String username,
      String password,
      String dateReg,
      String email,
      String fullname,
      String lastname,
      String gender,
      String birthdate) async {
    Database db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
      'date_reg': dateReg,
      'email': email,
      'fullname': fullname,
      'lastname': lastname,
      'gender': gender,
      'birthdate': birthdate
    });
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> insertUser1(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.update('users', user,
        where: 'user_id = ?', whereArgs: [user['user_id']]);
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }
}
