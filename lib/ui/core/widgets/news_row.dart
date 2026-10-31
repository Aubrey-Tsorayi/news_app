import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/routing/routes.dart';

class NewsRow extends StatelessWidget {
  const NewsRow({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          Navigator.pushNamed(context, Routes.article, arguments: article),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20, bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.newsBrand, style: AppTextStyles.rowBrand),
            Text(
              article.title,
              style: AppTextStyles.rowTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
