import 'package:news_app/data/services/article_rows.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Low-level access to the on-device bookmarks table. Works with raw rows;
/// mapping to [Article] happens in the repository.
class BookmarkDatabaseService {
  BookmarkDatabaseService();

  static const tableName = 'bookmarks';
  static const savedAtColumn = 'saved_at';

  static const _version = 2;

  // opened once and reused for the lifetime of the service
  late final Future<Database> _database = _open();

  Future<Database> _open() async {
    final databasePath = join(await getDatabasesPath(), 'bookmarks.db');
    return openDatabase(
      databasePath,
      version: _version,
      onCreate: (db, version) => _createBookmarksTable(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        // version 1 only ever held the bundled sample articles, which no
        // longer exist, so the old table is replaced rather than migrated
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS $tableName');
          await _createBookmarksTable(db);
        }
      },
    );
  }

  static Future<void> _createBookmarksTable(Database db) {
    return db.execute('''
      CREATE TABLE $tableName (
        ${ArticleColumns.definitions},
        $savedAtColumn INTEGER NOT NULL
      )
      ''');
  }

  /// Newest saves first.
  Future<List<Map<String, Object?>>> getAll() async {
    final db = await _database;
    return db.query(tableName, orderBy: '$savedAtColumn DESC');
  }

  Future<void> insert(Map<String, Object?> row) async {
    final db = await _database;
    await db.insert(tableName, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db
        .delete(tableName, where: '${ArticleColumns.id} = ?', whereArgs: [id]);
  }
}
