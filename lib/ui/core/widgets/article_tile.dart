import 'package:flutter/material.dart';
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/routing/routes.dart';
import 'package:news_app/domain/models/news_source.dart';
import 'package:news_app/ui/core/widgets/access_label.dart';
import 'package:news_app/ui/core/widgets/article_image.dart';
import 'package:news_app/ui/core/widgets/bookmark_button.dart';
import 'package:news_app/ui/core/widgets/read_aware_text.dart';
import 'package:news_app/ui/core/widgets/source_logo.dart';
import 'package:news_app/utils/formatting.dart';

/// One article in a list: source and time, headline, a two-line summary so
/// readers can decide quickly whether to open it, and a save button.
class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article});

  final Article article;

  static const _thumbnailSize = 88.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final source = sourceById(article.sourceId);

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, Routes.article, arguments: article),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArticleMeta(
                          source: source,
                          publishedAt: article.publishedAt,
                        ),
                        const SizedBox(height: 6),
                        ArticleHeadline(
                          article: article,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.summary,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (article.imageUrl case final url?) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ArticleImage(
                        url: url,
                        width: _thumbnailSize,
                        height: _thumbnailSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                ReadingTimeLabel(article: article),
                const Spacer(),
                BookmarkButton(article: article),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "[logo] The Herald · 3 h ago · 🔓 Free"
class ArticleMeta extends StatelessWidget {
  const ArticleMeta({
    super.key,
    required this.source,
    required this.publishedAt,
    this.logoSize = 16,
  });

  final NewsSource source;
  final DateTime publishedAt;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Row(
      children: [
        ExcludeSemantics(child: SourceLogo(source: source, size: logoSize)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '${source.name} · ${timeAgo(publishedAt)}',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(' · ', style: style),
        AccessLabel(source: source, style: style),
      ],
    );
  }
}
