import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Low-level access to the on-device bookmarks table. Works with raw rows;
/// mapping to [Article] happens in the repository.
class BookmarkDatabaseService {
  BookmarkDatabaseService();

  static const tableName = 'bookmarks';
  static const idColumn = 'id';
  static const sourceIdColumn = 'source_id';
  static const titleColumn = 'title';
  static const urlColumn = 'url';
  static const publishedAtColumn = 'published_at';
  static const summaryColumn = 'summary';
  static const authorColumn = 'author';
  static const contentColumn = 'content';
  static const imageUrlColumn = 'image_url';
  static const isTruncatedColumn = 'is_truncated';
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
        $idColumn TEXT PRIMARY KEY,
        $sourceIdColumn TEXT NOT NULL,
        $titleColumn TEXT NOT NULL,
        $urlColumn TEXT NOT NULL,
        $publishedAtColumn INTEGER NOT NULL,
        $summaryColumn TEXT NOT NULL,
        $authorColumn TEXT,
        $contentColumn TEXT NOT NULL,
        $imageUrlColumn TEXT,
        $isTruncatedColumn INTEGER NOT NULL,
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
    await db.delete(tableName, where: '$idColumn = ?', whereArgs: [id]);
  }
}
