import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/providers/bookmarks_provider.dart';
import 'package:news_app/utilities/colors.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmark = ref.watch(bookmarkedIdsProvider).contains(article.id);

    return Container(
      margin: const EdgeInsets.only(right: 20),
      height: 150,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 20,
            child: Image.asset(
              article.imageUrl,
              fit: BoxFit.scaleDown,
              width: 150,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(bookmarkNotifierProvider.notifier)
                    .toggleBookmark(article);
              },
              child: Icon(
                isBookmark ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: primaryColor,
                size: 25,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 10,
            child: SizedBox(
              width: 200,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "SF Pro Text",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
