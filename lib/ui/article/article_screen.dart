import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/core/widgets/bookmark_button.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        actions: [
          // TODO: implement sharing
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.share_sharp),
          ),
          BookmarkButton(
            article: article,
            outlinedIcon: Icons.bookmark_border,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.5),
              child: Image.asset(
                "assets/images/news-article.png",
                height: width * 0.6,
                width: width * 0.9,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  article.newsBrand,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(article.title, style: AppTextStyles.articleTitle),
            const SizedBox(height: 10),
            Text("By ${article.author} · ${article.date}",
                style: AppTextStyles.author),
            const SizedBox(height: 20),
            Text(article.article, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
