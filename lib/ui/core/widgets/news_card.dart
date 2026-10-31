import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/routing/routes.dart';
import 'package:news_app/ui/core/widgets/bookmark_button.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.article,
  });

  final Article article;

  static const width = 250.0;
  static const height = 150.0;

  static final _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: primaryColor, width: 2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x809E9E9E), // grey at 50% opacity
        spreadRadius: 2,
        blurRadius: 2,
        offset: Offset(5, 0),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, Routes.article, arguments: article),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        height: height,
        width: width,
        decoration: _decoration,
        child: Stack(
          children: [
            Positioned(
              top: 25,
              left: 20,
              child: Image.asset(
                article.imageUrl,
                fit: BoxFit.scaleDown,
                width: 150,
                // decode at display size instead of full resolution
                cacheWidth: (150 * pixelRatio).round(),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: BookmarkButton(article: article),
            ),
            Positioned(
              left: 20,
              bottom: 10,
              child: SizedBox(
                width: 200,
                child: Text(
                  article.title,
                  style: AppTextStyles.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
