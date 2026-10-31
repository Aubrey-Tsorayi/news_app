import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/domain/models/news_brand.dart';
import 'package:news_app/ui/core/widgets/header.dart';
import 'package:news_app/ui/core/widgets/news_card.dart';
import 'package:news_app/ui/core/widgets/news_row.dart';
import 'package:news_app/ui/home/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // each section watches only the state it needs, so selecting a brand
    // doesn't rebuild the "More news" list
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 25, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                  heading: "Browse", subtext: "Discover today's news update"),
              SizedBox(height: 20),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: _BrandChips()),
                    SliverToBoxAdapter(child: SizedBox(height: 30)),
                    SliverToBoxAdapter(child: _Headlines()),
                    SliverToBoxAdapter(child: SizedBox(height: 25)),
                    SliverToBoxAdapter(
                      child: Text("More news for you",
                          style: AppTextStyles.sectionTitle),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 20)),
                    _MoreNews(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandChips extends ConsumerWidget {
  const _BrandChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsProvider);
    final selected = ref.watch(selectedBrandProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return _BrandChip(
            brand: brand,
            isSelected: brand == selected,
            onTap: () => ref.read(selectedBrandProvider.notifier).select(brand),
          );
        },
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.brand,
    required this.isSelected,
    required this.onTap,
  });

  final NewsBrand brand;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          brand.name,
          style: AppTextStyles.chip.copyWith(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _Headlines extends ConsumerWidget {
  const _Headlines();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headlines = ref.watch(headlinesProvider);

    return SizedBox(
      // extra room so the card shadow isn't clipped
      height: NewsCard.height + 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: headlines.length,
        itemBuilder: (context, index) => Align(
          alignment: Alignment.topLeft,
          child: NewsCard(
            key: ValueKey(headlines[index].id),
            article: headlines[index],
          ),
        ),
      ),
    );
  }
}

class _MoreNews extends ConsumerWidget {
  const _MoreNews();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(allArticlesProvider);

    return SliverList.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => NewsRow(
        key: ValueKey(articles[index].id),
        article: articles[index],
      ),
    );
  }
}
