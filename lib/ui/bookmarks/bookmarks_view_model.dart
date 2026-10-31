import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/bookmark_repository.dart';
import 'package:news_app/domain/models/article.dart';

class BookmarksViewModel extends AsyncNotifier<List<Article>> {
  BookmarkRepository get _repository => ref.read(bookmarkRepositoryProvider);

  @override
  Future<List<Article>> build() {
    return ref.watch(bookmarkRepositoryProvider).getBookmarks();
  }

  Future<void> toggle(Article article) {
    final saved = state.valueOrNull ?? const [];
    return saved.contains(article) ? remove(article) : add(article);
  }

  // update the list straight away, then write to the database; roll back if
  // the write fails so the UI never shows a bookmark that wasn't saved
  Future<void> add(Article article) async {
    final previous = state;
    state = AsyncData([
      article,
      for (final a in previous.valueOrNull ?? const <Article>[])
        if (a != article) a,
    ]);
    try {
      await _repository.addBookmark(article);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> remove(Article article) async {
    final previous = state;
    state = AsyncData([
      for (final a in previous.valueOrNull ?? const <Article>[])
        if (a != article) a,
    ]);
    try {
      await _repository.removeBookmark(article.id);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final bookmarksViewModelProvider =
    AsyncNotifierProvider<BookmarksViewModel, List<Article>>(
        BookmarksViewModel.new);

final _bookmarkedIdsProvider = Provider<Set<String>>((ref) {
  final bookmarks = ref.watch(bookmarksViewModelProvider).valueOrNull;
  return {for (final a in bookmarks ?? const <Article>[]) a.id};
});

/// Whether one article is bookmarked. Widgets watch this instead of the whole
/// list, so toggling one bookmark only rebuilds that article's icon.
final isBookmarkedProvider = Provider.family<bool, String>((ref, articleId) {
  return ref.watch(_bookmarkedIdsProvider).contains(articleId);
});
