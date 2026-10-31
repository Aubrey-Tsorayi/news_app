import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/repositories/reading_history_repository.dart';
import 'package:news_app/ui/history/read_articles_view_model.dart';

class FakeReadingHistoryRepository implements ReadingHistoryRepository {
  final readIds = <String>{};
  var writes = 0;
  bool failWrites = false;

  @override
  Future<Set<String>> getReadIds() async => {...readIds};

  @override
  Future<void> markRead(String articleId) async {
    if (failWrites) throw Exception('disk full');
    writes++;
    readIds.add(articleId);
  }
}

void main() {
  late FakeReadingHistoryRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeReadingHistoryRepository();
    container = ProviderContainer(overrides: [
      readingHistoryRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('loads what was read before', () async {
    repository.readIds.add('a');
    await container.read(readArticlesViewModelProvider.future);
    expect(container.read(isReadProvider('a')), isTrue);
    expect(container.read(isReadProvider('b')), isFalse);
  });

  test('markRead saves, then shows the article as read', () async {
    await container.read(readArticlesViewModelProvider.future);
    await container.read(readArticlesViewModelProvider.notifier).markRead('a');

    expect(repository.readIds, {'a'});
    expect(container.read(isReadProvider('a')), isTrue);
  });

  test('reopening a read article does not write again', () async {
    await container.read(readArticlesViewModelProvider.future);
    final viewModel = container.read(readArticlesViewModelProvider.notifier);
    await viewModel.markRead('a');
    await viewModel.markRead('a');
    expect(repository.writes, 1);
  });

  test('a failed save leaves the article unread', () async {
    await container.read(readArticlesViewModelProvider.future);
    repository.failWrites = true;

    await expectLater(
      container.read(readArticlesViewModelProvider.notifier).markRead('a'),
      throwsException,
    );
    expect(container.read(isReadProvider('a')), isFalse);
  });
}
