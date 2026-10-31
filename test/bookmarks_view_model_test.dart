import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/repositories/bookmark_repository.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';

class FakeBookmarkRepository implements BookmarkRepository {
  final saved = <String, Article>{};
  bool failWrites = false;

  @override
  Future<List<Article>> getBookmarks() async => saved.values.toList();

  @override
  Future<void> addBookmark(Article article) async {
    if (failWrites) throw Exception('disk full');
    saved[article.id] = article;
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    if (failWrites) throw Exception('disk full');
    saved.remove(articleId);
  }
}

Article article(String id) => Article(
      id: id,
      sourceId: 'herald',
      title: 'Title $id',
      url: id,
      publishedAt: DateTime.utc(2026, 10, 31),
      summary: 'Summary',
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
    final a = article('https://example.com/a');
    await container.read(bookmarksViewModelProvider.future);
    final viewModel = container.read(bookmarksViewModelProvider.notifier);

    await viewModel.toggle(a);
    expect(container.read(isBookmarkedProvider(a.id)), isTrue);
    expect(repository.saved.keys, [a.id]);

    await viewModel.toggle(a);
    expect(container.read(isBookmarkedProvider(a.id)), isFalse);
    expect(repository.saved, isEmpty);
  });

  test('newest bookmark is listed first', () async {
    await container.read(bookmarksViewModelProvider.future);
    final viewModel = container.read(bookmarksViewModelProvider.notifier);

    await viewModel.add(article('1'));
    await viewModel.add(article('2'));
    expect(container.read(bookmarksViewModelProvider).value!.map((a) => a.id),
        ['2', '1']);
  });

  test('loads existing bookmarks from the repository', () async {
    final a = article('https://example.com/a');
    repository.saved[a.id] = a;
    final bookmarks = await container.read(bookmarksViewModelProvider.future);
    expect(bookmarks, [a]);
  });

  test('rolls back when the write fails', () async {
    final a = article('https://example.com/a');
    await container.read(bookmarksViewModelProvider.future);
    repository.failWrites = true;

    await expectLater(
      container.read(bookmarksViewModelProvider.notifier).toggle(a),
      throwsException,
    );
    expect(container.read(isBookmarkedProvider(a.id)), isFalse);
  });
}
