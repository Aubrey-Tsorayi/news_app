import 'package:flutter/material.dart';
import 'package:news_app/domain/models/news_source.dart';

/// A newspaper's logo on a white tile, so it reads in light and dark mode.
class SourceLogo extends StatelessWidget {
  const SourceLogo({super.key, required this.source, this.size = 20});

  final NewsSource source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Container(
      width: size * 1.6,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Image.asset(
        source.logoAsset,
        fit: BoxFit.contain,
        // decode at display size instead of full resolution
        cacheWidth: (size * 1.6 * pixelRatio).round(),
        semanticLabel: source.name,
      ),
    );
  }
}
