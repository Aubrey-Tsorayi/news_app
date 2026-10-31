import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';

/// Saves or removes an article. Only this widget rebuilds when its article's
/// bookmark state changes.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isBookmarkedProvider(article.id));

    return IconButton(
      tooltip: isSaved ? 'Remove from saved' : 'Save for later',
      isSelected: isSaved,
      icon: const Icon(Icons.bookmark_add_outlined),
      selectedIcon: Icon(
        Icons.bookmark,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref.read(bookmarksViewModelProvider.notifier).toggle(article);
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text("Couldn't update saved articles")),
          );
        }
      },
    );
  }
}
