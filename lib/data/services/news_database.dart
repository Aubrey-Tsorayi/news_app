import 'package:news_app/data/services/article_rows.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The on-device database for the news feed: the article cache and reading
/// history. Kept in its own file, separate from bookmarks, so clearing the
/// cache can never touch saved articles.
class NewsDatabase {
  NewsDatabase();

  static const articlesTable = 'articles';
  static const fetchedAtColumn = 'fetched_at';

  static const readTable = 'read_articles';
  static const readIdColumn = 'id';
  static const readAtColumn = 'read_at';

  static const _version = 2;

  /// Opened once and shared by every store that uses it.
  late final Future<Database> database = _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'articles.db');
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await _createArticles(db);
        await _createReadArticles(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createReadArticles(db);
      },
    );
  }

  static Future<void> _createArticles(Database db) async {
    await db.execute('''
      CREATE TABLE $articlesTable (
        ${ArticleColumns.definitions},
        $fetchedAtColumn INTEGER NOT NULL
      )
      ''');
    await db.execute('CREATE INDEX idx_articles_published '
        'ON $articlesTable (${ArticleColumns.publishedAt})');
  }

  static Future<void> _createReadArticles(Database db) {
    return db.execute('''
      CREATE TABLE $readTable (
        $readIdColumn TEXT PRIMARY KEY,
        $readAtColumn INTEGER NOT NULL
      )
      ''');
  }
}
