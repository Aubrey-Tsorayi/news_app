import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/providers/article_provider.dart';
import 'package:news_app/providers/bookmarks_provider.dart';
import 'package:news_app/providers/news_brands_provider.dart';
import 'package:news_app/utilities/colors.dart';
import 'package:news_app/widgets/header.dart';
import 'package:news_app/widgets/news_card.dart';
import 'package:news_app/widgets/news_row.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // notifier
    final brands = ref.watch(newsBrandsNotifierProvider);
    final headlines = ref.watch(selectedBrandsArticlesProvider);
    final allArticles = ref.watch(allArticlesProvider);
    final bookmarks = ref.watch(bookmarkNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 25, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderText(
                  heading: "Browse", subtext: "Discover today's news update"),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var brand in brands)
                              GestureDetector(
                                // update the isSelected property of the brand
                                onTap: () {
                                  ref
                                      .read(newsBrandsNotifierProvider.notifier)
                                      .updateBrand(brand);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: brand.isSelected
                                        ? primaryColor
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      brand.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "SF Pro Text",
                                        fontWeight: FontWeight.w600,
                                        color: brand.isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: headlines.map((article) {
                            return NewsCard(
                              id: article.id,
                              title: article.title,
                              image: article.imageUrl,
                              isBookmark: article.isBookmarked,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "More news for you",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "SF Pro Text",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: allArticles.map((story) {
                              return NewsRow(
                                id: story.id,
                                title: story.title,
                                newsBrand: story.newsBrand,
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
