import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';

/// Toggles a bookmark. Only this widget rebuilds when its article's bookmark
/// state changes.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    super.key,
    required this.article,
    this.outlinedIcon = Icons.bookmark_add_outlined,
  });

  final Article article;
  final IconData outlinedIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(isBookmarkedProvider(article.id));

    return IconButton(
      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
      onPressed: () =>
          ref.read(bookmarksViewModelProvider.notifier).toggle(article),
      icon: Icon(
        isBookmarked ? Icons.bookmark : outlinedIcon,
        color: primaryColor,
        size: 25,
      ),
    );
  }
}
