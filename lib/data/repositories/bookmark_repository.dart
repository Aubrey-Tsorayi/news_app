import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/services/bookmark_database_service.dart';
import 'package:news_app/domain/models/article.dart';

typedef _Db = BookmarkDatabaseService;

/// Source of truth for saved articles, stored locally on the device. Saved
/// articles keep their full text so they can be read offline.
abstract class BookmarkRepository {
  Future<List<Article>> getBookmarks();
  Future<void> addBookmark(Article article);
  Future<void> removeBookmark(String articleId);
}

class LocalBookmarkRepository implements BookmarkRepository {
  LocalBookmarkRepository(this._db);

  final BookmarkDatabaseService _db;

  // paragraphs are stored as one text column, separated by blank lines
  static const _paragraphSeparator = '\n\n';

  @override
  Future<List<Article>> getBookmarks() async {
    final rows = await _db.getAll();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> addBookmark(Article article) => _db.insert(_toRow(article));

  @override
  Future<void> removeBookmark(String articleId) => _db.delete(articleId);

  static Article _fromRow(Map<String, Object?> row) {
    final content = row[_Db.contentColumn] as String;
    return Article(
      id: row[_Db.idColumn] as String,
      sourceId: row[_Db.sourceIdColumn] as String,
      title: row[_Db.titleColumn] as String,
      url: row[_Db.urlColumn] as String,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
          row[_Db.publishedAtColumn] as int),
      summary: row[_Db.summaryColumn] as String,
      author: row[_Db.authorColumn] as String?,
      paragraphs:
          content.isEmpty ? const [] : content.split(_paragraphSeparator),
      imageUrl: row[_Db.imageUrlColumn] as String?,
      isTruncated: row[_Db.isTruncatedColumn] == 1,
    );
  }

  static Map<String, Object?> _toRow(Article article) => {
        _Db.idColumn: article.id,
        _Db.sourceIdColumn: article.sourceId,
        _Db.titleColumn: article.title,
        _Db.urlColumn: article.url,
        _Db.publishedAtColumn: article.publishedAt.millisecondsSinceEpoch,
        _Db.summaryColumn: article.summary,
        _Db.authorColumn: article.author,
        _Db.contentColumn: article.paragraphs.join(_paragraphSeparator),
        _Db.imageUrlColumn: article.imageUrl,
        _Db.isTruncatedColumn: article.isTruncated ? 1 : 0,
        _Db.savedAtColumn: DateTime.now().millisecondsSinceEpoch,
      };
}

final bookmarkDatabaseServiceProvider =
    Provider<BookmarkDatabaseService>((ref) => BookmarkDatabaseService());

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return LocalBookmarkRepository(ref.watch(bookmarkDatabaseServiceProvider));
});
