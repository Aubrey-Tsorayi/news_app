import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';
import 'package:news_app/ui/core/widgets/article_tile.dart';
import 'package:news_app/ui/core/widgets/state_views.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksViewModelProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxReadingWidth + 40),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.medium(title: Text('Saved')),
            bookmarks.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(
                  icon: Icons.error_outline,
                  title: "Couldn't open saved articles",
                  message: 'Try restarting the app.',
                ),
              ),
              data: (articles) => articles.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: MessageView(
                        icon: Icons.bookmarks_outlined,
                        title: 'Nothing saved yet',
                        message: 'Tap the bookmark on any story to read it '
                            'later, even offline.',
                      ),
                    )
                  : SliverList.separated(
                      itemCount: articles.length,
                      itemBuilder: (context, index) =>
                          _DismissibleTile(article: articles[index]),
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe left to remove, with undo.
class _DismissibleTile extends ConsumerWidget {
  const _DismissibleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colors.errorContainer,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      onDismissed: (_) {
        final viewModel = ref.read(bookmarksViewModelProvider.notifier);
        viewModel.remove(article);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: const Text('Removed from saved'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => viewModel.add(article),
            ),
          ));
      },
      child: ArticleTile(article: article),
    );
  }
}
