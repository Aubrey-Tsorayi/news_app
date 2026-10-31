import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/database/database_services.dart';
import 'package:news_app/models/article_model.dart';

class BookmarkNotifier extends AsyncNotifier<List<Article>> {
  final _db = DatabaseService.instance;

  @override
  Future<List<Article>> build() {
    return _db.getBookmarks();
  }

  Future<void> addBookmark(Article article) async {
    await _db.addBookMark(article);
    state = AsyncData(await _db.getBookmarks());
  }

  Future<void> removeBookmark(Article article) async {
    await _db.deleteBookMark(article.id);
    state = AsyncData(await _db.getBookmarks());
  }

  Future<void> toggleBookmark(Article article) {
    final isSaved = state.valueOrNull?.any((a) => a.id == article.id) ?? false;
    return isSaved ? removeBookmark(article) : addBookmark(article);
  }
}

final bookmarkNotifierProvider =
    AsyncNotifierProvider<BookmarkNotifier, List<Article>>(() {
  return BookmarkNotifier();
});

// ids of the saved articles, used to show the bookmark icon state
final bookmarkedIdsProvider = Provider<Set<int>>((ref) {
  final bookmarks = ref.watch(bookmarkNotifierProvider).valueOrNull ?? [];
  return bookmarks.map((a) => a.id).toSet();
});
