// import 'dart:typed_data';

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
      version: 4,
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
    await db.execute('''CREATE TABLE trash(
        trash_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        trash_name TEXT, 
        trash_type TEXT,
        trash_des TEXT,
        trash_pic BLOB )''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''CREATE TABLE trash(
        trash_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        trash_name TEXT, 
        trash_type TEXT,
        trash_des TEXT,
        trash_pic BLOB )''');
    }
  }

  Future<int> insertTrash(
    String trashname,
    String trashtype,
    String trashdes,
    // Uint8List trashpic,
  ) async {
    Database db = await database;
    return await db.insert('trash', {
      'trash_name': trashname,
      'trash_type': trashtype,
      'trash_des': trashdes,
      // 'trash_pic': trashpic,
    });
  }

  Future<int> insertUser(
    String username,
    String password,
    String dateReg,
    String email,
    String fullname,
    String lastname,
    String gender,
    String birthdate,
  ) async {
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

  Future<List<Map<String, dynamic>>> getTrash() async {
    final db = await database;
    return await db.query('trash');
  }

  Future<List<Map<String, dynamic>>> getGeneralTrash() async {
    final db = await database;
    return await db
        .query('trash', where: 'trash_type = ?', whereArgs: ['ขยะทั่วไป']);
  }

  Future<List<Map<String, dynamic>>> getGTrashItem(
      String trashnamesearch) async {
    final db = await database;
    return await db
        .query('trash', where: 'trash_name = ?', whereArgs: [trashnamesearch]);
  }

  Future<void> insertUser1(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertTrash1(Map<String, dynamic> newTrash) async {
    final db = await database;
    await db.insert('trash', newTrash,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.update('users', user,
        where: 'user_id = ?', whereArgs: [user['user_id']]);
  }

  Future<void> updateTrash(Map<String, dynamic> trash) async {
    final db = await database;
    await db.update('trash', trash,
        where: 'trash_id = ?', whereArgs: [trash['trash_id']]);
  }

  Future<void> updatePassword(String username, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }

  Future<void> deleteTrash(int id) async {
    final db = await database;
    await db.delete('trash', where: 'trash_id = ?', whereArgs: [id]);
  }
}
