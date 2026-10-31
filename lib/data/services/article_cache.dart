import 'package:news_app/data/services/article_rows.dart';
import 'package:news_app/data/services/news_database.dart';
import 'package:news_app/domain/models/article.dart';
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
  SqfliteArticleCache(this._db);

  final NewsDatabase _db;

  static const _table = NewsDatabase.articlesTable;
  static const _fetchedAt = NewsDatabase.fetchedAtColumn;

  Future<Database> get _database => _db.database;

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
