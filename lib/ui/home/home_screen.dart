import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/news_source.dart';
import 'package:news_app/routing/routes.dart';
import 'package:news_app/ui/core/widgets/article_tile.dart';
import 'package:news_app/ui/core/widgets/featured_article_card.dart';
import 'package:news_app/ui/core/widgets/state_views.dart';
import 'package:news_app/ui/home/home_view_model.dart';
import 'package:news_app/utils/formatting.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // news moves fast; refresh when the reader comes back after a while
  static const _staleAfter = Duration(minutes: 15);

  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => ref
        .read(feedViewModelProvider.notifier)
        .refreshIfOlderThan(_staleAfter),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // start listening
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(feedViewModelProvider.notifier).refresh();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
        content: Text("Couldn't refresh. Check your connection."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxReadingWidth + 40),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar.medium(
                title: Text('Today'),
                actions: [_SearchButton()],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(24),
                  child: _DateLine(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SourceFilterHeader(),
              ),
              _FeedStatusNotice(),
              _Feed(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Search',
      icon: const Icon(Icons.search),
      onPressed: () => Navigator.pushNamed(context, Routes.search),
    );
  }
}

/// "Saturday, 31 October · Updated 5 min ago"
class _DateLine extends ConsumerWidget {
  const _DateLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final updatedAt = ref.watch(
        feedViewModelProvider.select((feed) => feed.valueOrNull?.updatedAt));
    final text = [
      longDate(DateTime.now()),
      if (updatedAt != null) 'Updated ${timeAgoInline(updatedAt)}',
    ].join(' · ');

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SourceFilterHeader extends SliverPersistentHeaderDelegate {
  const _SourceFilterHeader();

  static const _height = 56.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const _SourceChips(),
    );
  }

  @override
  bool shouldRebuild(_SourceFilterHeader oldDelegate) => false;
}

class _SourceChips extends ConsumerWidget {
  const _SourceChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSourceProvider);
    final notifier = ref.read(selectedSourceProvider.notifier);
    final sources = <NewsSource?>[null, ...newsSources];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // the unread filter first, then one chip per paper
      itemCount: sources.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        if (index == 0) return const _UnreadOnlyChip();
        final source = sources[index - 1];
        final isPaid = source?.isPaid ?? false;
        return ChoiceChip(
          avatar: isPaid ? const Icon(Icons.lock_outline, size: 16) : null,
          tooltip: isPaid ? 'Full stories need a subscription' : null,
          label: Text(source?.name ?? 'All papers'),
          selected: selected == source?.id,
          onSelected: (_) => notifier.select(source?.id),
        );
      },
    );
  }
}

class _UnreadOnlyChip extends ConsumerWidget {
  const _UnreadOnlyChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadOnly = ref.watch(unreadOnlyProvider);
    return FilterChip(
      avatar: Icon(unreadOnly ? Icons.mark_email_unread : Icons.filter_list,
          size: 18),
      label: const Text('Unread'),
      tooltip: unreadOnly ? 'Show all stories' : 'Hide stories you have read',
      selected: unreadOnly,
      onSelected: (_) => ref.read(unreadOnlyProvider.notifier).toggle(),
    );
  }
}

/// Explains when the feed isn't fully up to date: offline, or some papers
/// unreachable.
class _FeedStatusNotice extends ConsumerWidget {
  const _FeedStatusNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (isOffline, failed, updatedAt) =
        ref.watch(feedViewModelProvider.select((feed) => (
              feed.valueOrNull?.isOffline ?? false,
              feed.valueOrNull?.failedSources ?? const [],
              feed.valueOrNull?.updatedAt,
            )));

    final String message;
    if (isOffline) {
      message = updatedAt == null
          ? "You're offline. Showing saved stories."
          : "You're offline. Showing stories from "
              '${timeAgoInline(updatedAt)}.';
    } else if (failed.isNotEmpty) {
      final names = failed.map((s) => s.name).join(', ');
      message = "Couldn't reach $names. Pull down to try again.";
    } else {
      return const SliverToBoxAdapter();
    }

    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feed extends ConsumerWidget {
  const _Feed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(visibleArticlesProvider);

    return articles.when(
      skipLoadingOnRefresh: true,
      loading: () => SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const ArticleSkeleton(),
      ),
      error: (_, __) => SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.wifi_off,
          title: "Couldn't load the news",
          message: 'Check your internet connection and try again.',
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(feedViewModelProvider),
            child: const Text('Try again'),
          ),
        ),
      ),
      data: (articles) {
        if (articles.isEmpty) {
          final caughtUp = ref.watch(unreadOnlyProvider);
          return SliverFillRemaining(
            hasScrollBody: false,
            child: caughtUp
                ? const MessageView(
                    icon: Icons.done_all,
                    title: "You're all caught up",
                    message: "You've read every story here. Pull down to "
                        'check for new ones.',
                  )
                : const MessageView(
                    icon: Icons.inbox_outlined,
                    title: 'No stories yet',
                    message: 'This paper has nothing new right now.',
                  ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList.separated(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: FeaturedArticleCard(
                      key: ValueKey(article.id), article: article),
                );
              }
              return ArticleTile(key: ValueKey(article.id), article: article);
            },
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox.shrink()
                : const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        );
      },
    );
  }
}
