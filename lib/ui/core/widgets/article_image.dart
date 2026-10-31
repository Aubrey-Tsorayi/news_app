import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image cached on disk, decoded at the size it's displayed.
class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.url,
    required this.width,
    this.height,
  });

  final String url;
  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final placeholder = ColoredBox(color: colors.surfaceContainerHighest);

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: width.isFinite ? (width * pixelRatio).round() : null,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
