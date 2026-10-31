import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/history/read_articles_view_model.dart';

/// An article's headline, dimmed once it has been read. Only this widget
/// rebuilds when the article's read state changes.
class ArticleHeadline extends ConsumerWidget {
  const ArticleHeadline({
    super.key,
    required this.article,
    required this.style,
    this.maxLines,
  });

  final Article article;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = ref.watch(isReadProvider(article.id));
    final colors = Theme.of(context).colorScheme;

    return Text(
      article.title,
      style: isRead ? style?.copyWith(color: colors.onSurfaceVariant) : style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// "◷ 3 min read", or "✓ Read · 3 min" once opened, so read state is shown by
/// an icon and words as well as the dimmed headline.
class ReadingTimeLabel extends ConsumerWidget {
  const ReadingTimeLabel({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = ref.watch(isReadProvider(article.id));
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isRead ? Icons.check_circle_outline : Icons.schedule,
            size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          isRead
              ? 'Read · ${article.readingMinutes} min'
              : '${article.readingMinutes} min read',
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
