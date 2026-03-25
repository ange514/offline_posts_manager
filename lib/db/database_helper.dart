import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  // Singleton pattern - only one instance of the DB helper exists
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Lazily initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'posts.db');

      return await openDatabase(path, version: 1, onCreate: _createTable);
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        author TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────

  Future<int> insertPost(Post post) async {
    try {
      final db = await database;
      return await db.insert(
        'posts',
        post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert post: $e');
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  Future<List<Post>> getAllPosts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'posts',
        orderBy: 'id DESC',
      );
      return maps.map((map) => Post.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<Post?> getPostById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Post.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to fetch post with id $id: $e');
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<int> updatePost(Post post) async {
    try {
      if (post.id == null) throw Exception('Cannot update post without an id');
      final db = await database;
      return await db.update(
        'posts',
        post.toMap(),
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<int> deletePost(int id) async {
    try {
      final db = await database;
      return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
