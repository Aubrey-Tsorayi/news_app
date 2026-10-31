import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Low-level access to the on-device bookmarks table. Works with raw rows;
/// mapping to [Article] happens in the repository.
class BookmarkDatabaseService {
  BookmarkDatabaseService();

  static const tableName = 'bookmarks';
  static const idColumn = 'id';
  static const newsBrandColumn = 'newsBrand';
  static const titleColumn = 'title';
  static const authorColumn = 'author';
  static const dateColumn = 'date';
  static const imageUrlColumn = 'imageUrl';
  static const articleColumn = 'article';
  static const isBookmarkedColumn = 'isBookmarked';

  // opened once and reused for the lifetime of the service
  late final Future<Database> _database = _open();

  Future<Database> _open() async {
    final databasePath = join(await getDatabasesPath(), 'bookmarks.db');
    return openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
      // the id column holds the article's own id so bookmarks can be matched
      // back to articles
      await db.execute('''
      CREATE TABLE $tableName (
        $idColumn INTEGER PRIMARY KEY,
        $newsBrandColumn TEXT NOT NULL,
        $titleColumn TEXT NOT NULL,
        $authorColumn TEXT NOT NULL,
        $dateColumn TEXT NOT NULL,
        $imageUrlColumn TEXT NOT NULL,
        $articleColumn TEXT NOT NULL,
        $isBookmarkedColumn INTEGER NOT NULL
      )
      ''');
    });
  }

  Future<List<Map<String, Object?>>> getAll() async {
    final db = await _database;
    return db.query(tableName);
  }

  Future<void> insert(Map<String, Object?> row) async {
    final db = await _database;
    await db.insert(tableName, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(tableName, where: '$idColumn = ?', whereArgs: [id]);
  }
}
