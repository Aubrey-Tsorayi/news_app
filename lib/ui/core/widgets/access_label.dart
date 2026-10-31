import 'package:flutter/material.dart';
import 'package:news_app/domain/models/news_source.dart';

/// "🔓 Free" or "🔒 Subscription" for a paper, told by icon and word so it
/// doesn't rely on colour.
class AccessLabel extends StatelessWidget {
  const AccessLabel({super.key, required this.source, this.style});

  final NewsSource source;

  /// Text style; defaults to labelMedium in the muted on-surface colour.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = style ??
        theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Semantics(
      label: source.isPaid
          ? '${source.name} needs a subscription'
          : '${source.name} is free to read',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            source.isPaid ? Icons.lock_outline : Icons.lock_open_outlined,
            size: (textStyle?.fontSize ?? 12) + 2,
            color: textStyle?.color,
          ),
          const SizedBox(width: 3),
          Text(source.isPaid ? 'Subscription' : 'Free', style: textStyle),
        ],
      ),
    );
  }
}
