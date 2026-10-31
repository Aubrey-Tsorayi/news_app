import 'package:news_app/data/services/article_rows.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// On-device copy of recently fetched articles, so the feed opens instantly
/// and can be read offline.
abstract class ArticleCache {
  /// All cached articles, newest first.
  Future<List<Article>> getAll();

  /// Inserts or updates [articles], recording when they were fetched.
  Future<void> saveAll(List<Article> articles, {required DateTime fetchedAt});

  /// Removes articles published before [cutoff]. Returns how many were
  /// removed.
  Future<int> deletePublishedBefore(DateTime cutoff);

  /// When the feed was last fetched successfully, if ever.
  Future<DateTime?> lastFetchedAt();
}

class SqfliteArticleCache implements ArticleCache {
  SqfliteArticleCache();

  static const _table = 'articles';
  static const _fetchedAt = 'fetched_at';

  // opened once and reused for the lifetime of the cache
  late final Future<Database> _database = _open();

  Future<Database> _open() async {
    // separate file from bookmarks, so clearing the cache can never touch
    // saved articles
    final path = join(await getDatabasesPath(), 'articles.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $_table (
          ${ArticleColumns.definitions},
          $_fetchedAt INTEGER NOT NULL
        )
        ''');
      await db.execute('CREATE INDEX idx_articles_published '
          'ON $_table (${ArticleColumns.publishedAt})');
    });
  }

  @override
  Future<List<Article>> getAll() async {
    final db = await _database;
    final rows =
        await db.query(_table, orderBy: '${ArticleColumns.publishedAt} DESC');
    return rows.map(articleFromRow).toList();
  }

  @override
  Future<void> saveAll(List<Article> articles,
      {required DateTime fetchedAt}) async {
    final db = await _database;
    final batch = db.batch();
    for (final article in articles) {
      batch.insert(
        _table,
        {
          ...articleToRow(article),
          _fetchedAt: fetchedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<int> deletePublishedBefore(DateTime cutoff) async {
    final db = await _database;
    return db.delete(_table,
        where: '${ArticleColumns.publishedAt} < ?',
        whereArgs: [cutoff.millisecondsSinceEpoch]);
  }

  @override
  Future<DateTime?> lastFetchedAt() async {
    final db = await _database;
    final rows =
        await db.rawQuery('SELECT MAX($_fetchedAt) AS last FROM $_table');
    final last = rows.first['last'] as int?;
    return last == null ? null : DateTime.fromMillisecondsSinceEpoch(last);
  }
}
