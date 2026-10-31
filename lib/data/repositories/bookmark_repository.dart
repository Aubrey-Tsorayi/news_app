import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/services/bookmark_database_service.dart';
import 'package:news_app/domain/models/article.dart';

typedef _Db = BookmarkDatabaseService;

/// Source of truth for saved articles, stored locally on the device.
abstract class BookmarkRepository {
  Future<List<Article>> getBookmarks();
  Future<void> addBookmark(Article article);
  Future<void> removeBookmark(int articleId);
}

class LocalBookmarkRepository implements BookmarkRepository {
  LocalBookmarkRepository(this._db);

  final BookmarkDatabaseService _db;

  @override
  Future<List<Article>> getBookmarks() async {
    final rows = await _db.getAll();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> addBookmark(Article article) => _db.insert(_toRow(article));

  @override
  Future<void> removeBookmark(int articleId) => _db.delete(articleId);

  static Article _fromRow(Map<String, Object?> row) => Article(
        id: row[_Db.idColumn] as int,
        newsBrand: row[_Db.newsBrandColumn] as String,
        title: row[_Db.titleColumn] as String,
        author: row[_Db.authorColumn] as String,
        date: row[_Db.dateColumn] as String,
        imageUrl: row[_Db.imageUrlColumn] as String,
        article: row[_Db.articleColumn] as String,
      );

  static Map<String, Object?> _toRow(Article article) => {
        _Db.idColumn: article.id,
        _Db.newsBrandColumn: article.newsBrand,
        _Db.titleColumn: article.title,
        _Db.authorColumn: article.author,
        _Db.dateColumn: article.date,
        _Db.imageUrlColumn: article.imageUrl,
        _Db.articleColumn: article.article,
        _Db.isBookmarkedColumn: 1,
      };
}

final bookmarkDatabaseServiceProvider =
    Provider<BookmarkDatabaseService>((ref) => BookmarkDatabaseService());

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return LocalBookmarkRepository(ref.watch(bookmarkDatabaseServiceProvider));
});
