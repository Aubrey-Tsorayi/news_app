import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/providers/bookmarks_provider.dart';
import 'package:news_app/widgets/news_row.dart';
import 'package:news_app/widgets/no_bookmarks.dart';

import '../widgets/header.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({super.key});

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    final allBookmarks = ref.watch(bookmarkNotifierProvider);

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderText(
                heading: "Bookmarks", subtext: "Saved news articles"),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: allBookmarks.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => const Center(
                  child: Text("Couldn't load your bookmarks"),
                ),
                data: (bookmarks) => bookmarks.isEmpty
                    ? const NoBookmarks()
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: bookmarks.map((book) {
                            return NewsRow(
                              id: book.id,
                              title: book.title,
                              newsBrand: book.newsBrand,
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
