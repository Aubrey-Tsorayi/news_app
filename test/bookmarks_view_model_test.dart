import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/repositories/bookmark_repository.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';

class FakeBookmarkRepository implements BookmarkRepository {
  final saved = <int, Article>{};
  bool failWrites = false;

  @override
  Future<List<Article>> getBookmarks() async => saved.values.toList();

  @override
  Future<void> addBookmark(Article article) async {
    if (failWrites) throw Exception('disk full');
    saved[article.id] = article;
  }

  @override
  Future<void> removeBookmark(int articleId) async {
    if (failWrites) throw Exception('disk full');
    saved.remove(articleId);
  }
}

const article = Article(
  id: 1,
  newsBrand: 'The Herald',
  title: 'Title',
  author: 'Author',
  date: '1 June 2021',
  imageUrl: 'assets/images/herald.png',
  article: 'Body',
);

void main() {
  late FakeBookmarkRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeBookmarkRepository();
    container = ProviderContainer(overrides: [
      bookmarkRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('toggle saves then removes a bookmark', () async {
    await container.read(bookmarksViewModelProvider.future);
    final viewModel = container.read(bookmarksViewModelProvider.notifier);

    await viewModel.toggle(article);
    expect(container.read(isBookmarkedProvider(article.id)), isTrue);
    expect(repository.saved.keys, [article.id]);

    await viewModel.toggle(article);
    expect(container.read(isBookmarkedProvider(article.id)), isFalse);
    expect(repository.saved, isEmpty);
  });

  test('loads existing bookmarks from the repository', () async {
    repository.saved[article.id] = article;
    final bookmarks = await container.read(bookmarksViewModelProvider.future);
    expect(bookmarks, [article]);
  });

  test('rolls back when the write fails', () async {
    await container.read(bookmarksViewModelProvider.future);
    repository.failWrites = true;

    await expectLater(
      container.read(bookmarksViewModelProvider.notifier).toggle(article),
      throwsException,
    );
    expect(container.read(isBookmarkedProvider(article.id)), isFalse);
  });
}
