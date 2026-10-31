import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/services/article_rows.dart';
import 'package:news_app/data/services/bookmark_database_service.dart';
import 'package:news_app/domain/models/article.dart';

/// Source of truth for saved articles, stored locally on the device. Saved
/// articles keep their full text so they can be read offline, and are never
/// removed by the feed cache's cleanup.
abstract class BookmarkRepository {
  Future<List<Article>> getBookmarks();
  Future<void> addBookmark(Article article);
  Future<void> removeBookmark(String articleId);
}

class LocalBookmarkRepository implements BookmarkRepository {
  LocalBookmarkRepository(this._db);

  final BookmarkDatabaseService _db;

  @override
  Future<List<Article>> getBookmarks() async {
    final rows = await _db.getAll();
    return rows.map(articleFromRow).toList();
  }

  @override
  Future<void> addBookmark(Article article) => _db.insert({
        ...articleToRow(article),
        BookmarkDatabaseService.savedAtColumn:
            DateTime.now().millisecondsSinceEpoch,
      });

  @override
  Future<void> removeBookmark(String articleId) => _db.delete(articleId);
}

final bookmarkDatabaseServiceProvider =
    Provider<BookmarkDatabaseService>((ref) => BookmarkDatabaseService());

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return LocalBookmarkRepository(ref.watch(bookmarkDatabaseServiceProvider));
});
