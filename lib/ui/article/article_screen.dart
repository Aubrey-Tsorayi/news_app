import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_source.dart';
import 'package:news_app/ui/core/widgets/access_label.dart';
import 'package:news_app/ui/core/widgets/article_image.dart';
import 'package:news_app/ui/core/widgets/bookmark_button.dart';
import 'package:news_app/ui/core/widgets/source_logo.dart';
import 'package:news_app/ui/history/read_articles_view_model.dart';
import 'package:news_app/utils/formatting.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  Future<void> _openOriginal(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    // Custom Tabs keeps the reader in the app and uses their browser login,
    // so subscribers can read paywalled stories
    final opened = await launchUrl(Uri.parse(article.url),
        mode: LaunchMode.inAppBrowserView);
    if (!opened) {
      messenger.showSnackBar(
          const SnackBar(content: Text("Couldn't open the article")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final source = sourceById(article.sourceId);
    final body =
        article.paragraphs.isEmpty ? [article.summary] : article.paragraphs;
    final bodyStyle =
        theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 17);

    // over a photo, give the app bar buttons a backing so they stay
    // visible. This must be an IconButtonTheme widget: AppBar provides its
    // own IconButtonTheme, which takes precedence over ThemeData's.
    final buttonTheme = IconButtonThemeData(
      style: article.imageUrl == null
          ? null
          : IconButton.styleFrom(
              backgroundColor: colors.surface.withValues(alpha: 0.85),
              foregroundColor: colors.onSurface,
            ),
    );

    return _MarkReadOnOpen(
      articleId: article.id,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              // centred so the backing circle keeps its natural size instead
              // of stretching to fill the leading slot
              leading: Center(
                child: IconButtonTheme(
                    data: buttonTheme, child: const BackButton()),
              ),
              expandedHeight: article.imageUrl != null ? 260 : null,
              flexibleSpace: article.imageUrl == null
                  ? null
                  : FlexibleSpaceBar(
                      background: ArticleImage(
                        url: article.imageUrl!,
                        width: MediaQuery.sizeOf(context).width,
                      ),
                    ),
              actions: [
                IconButtonTheme(
                  data: buttonTheme,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Share',
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => SharePlus.instance.share(ShareParams(
                          text: '${article.title}\n${article.url}',
                          subject: article.title,
                        )),
                      ),
                      BookmarkButton(article: article),
                      IconButton(
                        tooltip: 'Open on ${source.name}',
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => _openOriginal(context),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxReadingWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ExcludeSemantics(
                                  child: SourceLogo(source: source, size: 22)),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(source.name,
                                    style: theme.textTheme.labelLarge),
                              ),
                              const SizedBox(width: 12),
                              _AccessBadge(source: source),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            article.title,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            [
                              if (article.author != null) article.author!,
                              fullDateTime(article.publishedAt),
                              '${article.readingMinutes} min read',
                            ].join(' · '),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const Divider(height: 32),
                          for (final paragraph in body)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(paragraph, style: bodyStyle),
                            ),
                          const SizedBox(height: 8),
                          _ContinueReading(
                            source: source,
                            isPreview: article.isTruncated,
                            onPressed: () => _openOriginal(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Records the article as read when the page opens.
class _MarkReadOnOpen extends ConsumerStatefulWidget {
  const _MarkReadOnOpen({required this.articleId, required this.child});

  final String articleId;
  final Widget child;

  @override
  ConsumerState<_MarkReadOnOpen> createState() => _MarkReadOnOpenState();
}

class _MarkReadOnOpenState extends ConsumerState<_MarkReadOnOpen> {
  @override
  void initState() {
    super.initState();
    unawaited(ref
        .read(readArticlesViewModelProvider.notifier)
        .markRead(widget.articleId)
        // a missed read marker isn't worth interrupting the reader for
        .catchError((Object error) => debugPrint('markRead failed: $error')));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// "🔓 Free" / "🔒 Subscription" in a tonal pill beside the paper's name.
class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.source});

  final NewsSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = source.isPaid
        ? colors.onTertiaryContainer
        : colors.onSecondaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: source.isPaid
            ? colors.tertiaryContainer
            : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AccessLabel(
          source: source,
          style: theme.textTheme.labelMedium?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _ContinueReading extends StatelessWidget {
  const _ContinueReading({
    required this.source,
    required this.isPreview,
    required this.onPressed,
  });

  final NewsSource source;
  final bool isPreview;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceName = source.name;

    if (!isPreview) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_new, size: 18),
        label: Text('View on $sourceName'),
      );
    }

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is a preview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              source.isPaid
                  ? 'The full story is for $sourceName subscribers. You can '
                      'sign in or subscribe on their site.'
                  : 'The full story is free to read on $sourceName.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text('Continue on $sourceName'),
            ),
          ],
        ),
      ),
    );
  }
}
