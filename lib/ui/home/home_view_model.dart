import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/article_repository.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_brand.dart';

final brandsProvider = Provider<List<NewsBrand>>((ref) {
  return ref.watch(articleRepositoryProvider).getBrands();
});

final allArticlesProvider = Provider<List<Article>>((ref) {
  return ref.watch(articleRepositoryProvider).getArticles();
});

/// The brand chip currently selected on the home screen.
class SelectedBrandNotifier extends Notifier<NewsBrand> {
  @override
  NewsBrand build() => ref.watch(brandsProvider).first;

  void select(NewsBrand brand) => state = brand;
}

final selectedBrandProvider =
    NotifierProvider<SelectedBrandNotifier, NewsBrand>(
        SelectedBrandNotifier.new);

/// Headlines for the selected brand; only recomputed when the brand changes.
final headlinesProvider = Provider<List<Article>>((ref) {
  final brand = ref.watch(selectedBrandProvider);
  return ref
      .watch(allArticlesProvider)
      .where((article) => article.newsBrand == brand.name)
      .toList(growable: false);
});
