import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/utilities/colors.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.isBookmark,
  });

  final int id;
  final String image;
  final String title;
  final bool isBookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              image,
              fit: BoxFit.scaleDown,
              width: 150,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                // ref.read(bookmarkNotifierProvider.notifier).addBookmark();
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
                title,
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
