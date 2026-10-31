import 'package:flutter/material.dart';
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/routing/routes.dart';
import 'package:news_app/ui/core/widgets/article_image.dart';
import 'package:news_app/ui/core/widgets/article_tile.dart';
import 'package:news_app/ui/core/widgets/bookmark_button.dart';
import 'package:news_app/ui/core/widgets/read_aware_text.dart';

/// The lead story at the top of the feed.
class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final source = sourceById(article.sourceId);

    return Card.filled(
      color: colors.surfaceContainerHigh,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, Routes.article, arguments: article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl case final url?)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      ArticleImage(url: url, width: constraints.maxWidth),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleMeta(
                    source: source,
                    publishedAt: article.publishedAt,
                    logoSize: 18,
                  ),
                  const SizedBox(height: 10),
                  ArticleHeadline(
                    article: article,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  ReadingTimeLabel(article: article),
                  const Spacer(),
                  BookmarkButton(article: article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
