import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/article_model.dart';

class BookmarkNotifier extends Notifier<Set<Article>> {
  @override
  Set<Article> build() {
    return {};
  }

  void addBookmark(Article article) {
    if (!state.contains(article)) {
      state = state.union({article});
    }
  }

  void removeBookmark(Article article) {
    if (!state.contains(article)) {
      state = state.where((a) => a.id != article.id).toSet();
    }
  }
}

final bookmarkNotifierProvider =
    NotifierProvider<BookmarkNotifier, Set<Article>>(() {
  return BookmarkNotifier();
});
