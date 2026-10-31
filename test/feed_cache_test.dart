import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/repositories/article_repository.dart';
import 'package:news_app/data/services/article_cache.dart';
import 'package:news_app/data/services/feed_service.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_source.dart';
import 'package:news_app/ui/home/home_view_model.dart';

final now = DateTime.utc(2026, 10, 31, 12);

const herald = NewsSource(
    id: 'herald', name: 'The Herald', feedUrl: 'h', logoAsset: 'h.png');
const daily = NewsSource(
    id: 'dailynews', name: 'Daily News', feedUrl: 'd', logoAsset: 'd.png');

Article article(String id, String sourceId, Duration age) => Article(
      id: id,
      sourceId: sourceId,
      title: id,
      url: id,
      publishedAt: now.subtract(age),
      summary: 'Summary',
    );

class FakeFeedService implements FeedService {
  final responses = <String, List<Article>>{};
  final failing = <String>{};

  @override
  Future<List<Article>> fetch(NewsSource source) async {
    if (failing.contains(source.id)) throw FeedException('${source.id} down');
    return responses[source.id] ?? const [];
  }
}

class FakeArticleCache implements ArticleCache {
  final stored = <String, Article>{};
  DateTime? fetchedAt;

  @override
  Future<List<Article>> getAll() async => stored.values.toList()
    ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  @override
  Future<void> saveAll(List<Article> articles,
      {required DateTime fetchedAt}) async {
    for (final a in articles) {
      stored[a.id] = a;
    }
    this.fetchedAt = fetchedAt;
  }

  @override
  Future<int> deletePublishedBefore(DateTime cutoff) async {
    final old = stored.values.where((a) => a.publishedAt.isBefore(cutoff));
    final ids = old.map((a) => a.id).toList();
    ids.forEach(stored.remove);
    return ids.length;
  }

  @override
  Future<DateTime?> lastFetchedAt() async => fetchedAt;
}

void main() {
  late FakeFeedService service;
  late FakeArticleCache cache;
  late FeedArticleRepository repository;

  setUp(() {
    service = FakeFeedService();
    cache = FakeArticleCache();
    repository = FeedArticleRepository(service, cache,
        sources: const [herald, daily], clock: () => now);
  });

  group('FeedArticleRepository', () {
    test('saves fetched articles and returns them newest first', () async {
      service.responses['herald'] = [article('h1', 'herald', Duration.zero)];
      service.responses['dailynews'] = [
        article('d1', 'dailynews', const Duration(hours: 1)),
      ];

      final result = await repository.fetchLatest();

      expect(result.articles.map((a) => a.id), ['h1', 'd1']);
      expect(result.updatedAt, now);
      expect(cache.stored.keys, containsAll(['h1', 'd1']));
    });

    test('drops articles older than a week', () async {
      cache.stored['old'] = article('old', 'herald', const Duration(days: 8));
      service.responses['herald'] = [
        article('h1', 'herald', Duration.zero),
        article('stale', 'herald', const Duration(days: 10)),
      ];

      final result = await repository.fetchLatest();

      expect(result.articles.map((a) => a.id), ['h1']);
    });

    test('a failed paper still shows its cached articles', () async {
      cache.stored['d-old'] =
          article('d-old', 'dailynews', const Duration(days: 1));
      service.responses['herald'] = [article('h1', 'herald', Duration.zero)];
      service.failing.add('dailynews');

      final result = await repository.fetchLatest();

      expect(result.articles.map((a) => a.id), ['h1', 'd-old']);
      expect(result.failedSources, [daily]);
    });

    test('throws when no paper can be reached', () async {
      service.failing.addAll(['herald', 'dailynews']);
      expect(repository.fetchLatest(), throwsA(isA<FeedException>()));
    });

    test('getCached is null until something has been fetched', () async {
      expect(await repository.getCached(), isNull);
      service.responses['herald'] = [article('h1', 'herald', Duration.zero)];
      await repository.fetchLatest();
      expect((await repository.getCached())!.updatedAt, now);
    });
  });

  group('FeedViewModel', () {
    ProviderContainer containerFor(ArticleRepository repository) {
      final container = ProviderContainer(overrides: [
        articleRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);
      return container;
    }

    test('shows cached articles first, then the fresh feed', () async {
      cache.stored['cached'] =
          article('cached', 'herald', const Duration(hours: 2));
      service.responses['herald'] = [article('fresh', 'herald', Duration.zero)];
      final container = containerFor(repository);

      final first = await container.read(feedViewModelProvider.future);
      expect(first.articles.map((a) => a.id), ['cached']);

      // let the background refresh finish
      await pumpEventQueue();
      final updated = container.read(feedViewModelProvider).value!;
      expect(updated.articles.map((a) => a.id), ['fresh', 'cached']);
      expect(updated.isOffline, isFalse);
    });

    test('marks the cached feed offline when the refresh fails', () async {
      cache.stored['cached'] =
          article('cached', 'herald', const Duration(hours: 2));
      service.failing.addAll(['herald', 'dailynews']);
      final container = containerFor(repository);

      await container.read(feedViewModelProvider.future);
      await pumpEventQueue();

      final feed = container.read(feedViewModelProvider).value!;
      expect(feed.articles.map((a) => a.id), ['cached']);
      expect(feed.isOffline, isTrue);
    });

    test('with an empty cache, waits for the network', () async {
      service.responses['herald'] = [article('h1', 'herald', Duration.zero)];
      final container = containerFor(repository);

      final feed = await container.read(feedViewModelProvider.future);
      expect(feed.articles.map((a) => a.id), ['h1']);
    });
  });
}
