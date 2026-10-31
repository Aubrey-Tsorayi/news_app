import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/ui/core/widgets/article_tile.dart';
import 'package:news_app/ui/core/widgets/state_views.dart';
import 'package:news_app/ui/search/search_view_model.dart';

/// Searches this week's stories and saved articles, on the device.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).update('');
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(searchQueryProvider.select((q) => q.isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search this week\'s news',
            border: InputBorder.none,
          ),
          onChanged: ref.read(searchQueryProvider.notifier).update,
        ),
        actions: [
          if (hasQuery)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: _clear,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxReadingWidth + 40),
          child: const _SearchResults(),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuery = ref.watch(searchQueryProvider.select((q) => q.isNotEmpty));
    final results = ref.watch(searchResultsProvider);

    if (!hasQuery) {
      return const MessageView(
        icon: Icons.search,
        title: 'Search the news',
        message: "Find stories from the past week and articles you've "
            'saved, even offline.',
      );
    }
    if (results.isEmpty) {
      return const MessageView(
        icon: Icons.search_off,
        title: 'No matches',
        message: 'Try fewer or different words.',
      );
    }

    return ListView.separated(
      // dismiss the keyboard when the reader starts scrolling the results
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _ResultCount(count: results.length);
        final article = results[index - 1];
        return ArticleTile(key: ValueKey(article.id), article: article);
      },
      separatorBuilder: (_, index) => index == 0
          ? const SizedBox.shrink()
          : const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Semantics(
        liveRegion: true,
        child: Text(
          count == 1 ? '1 story' : '$count stories',
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
