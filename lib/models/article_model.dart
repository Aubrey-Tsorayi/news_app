class Article {
  const Article({
    required this.id,
    required this.newsBrand,
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
    required this.article,
    required this.isBookmarked,
  });

  final int id;
  final String newsBrand;
  final String title;
  final String author;
  final String date;
  final String imageUrl;
  final String article;
  final bool isBookmarked;
}
