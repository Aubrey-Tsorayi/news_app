import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';
import 'package:news_app/ui/core/widgets/header.dart';
import 'package:news_app/ui/core/widgets/news_row.dart';
import 'package:news_app/ui/core/widgets/no_bookmarks.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderText(
                  heading: "Bookmarks", subtext: "Saved news articles"),
              const SizedBox(height: 20),
              Expanded(
                child: bookmarks.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => const Center(
                    child: Text("Couldn't load your bookmarks"),
                  ),
                  data: (articles) => articles.isEmpty
                      ? const NoBookmarks()
                      : ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) => NewsRow(
                            key: ValueKey(articles[index].id),
                            article: articles[index],
                          ),
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
