import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/news_brands_model.dart';

const List<NewsBrands> allBrands = [
  NewsBrands(name: "The Herald", isSelected: true),
  NewsBrands(name: "The Chronicle", isSelected: false),
  NewsBrands(name: "The Sunday Mail", isSelected: false),
  NewsBrands(name: "NewsDay", isSelected: false),
  NewsBrands(name: "The Financial Gazzette", isSelected: false),
  NewsBrands(name: "Zimbabwe Independent", isSelected: false),
  NewsBrands(name: "The Zimbabwean", isSelected: false),
  NewsBrands(name: "Daily News", isSelected: false),
];

class NewsBrandNotifier extends Notifier<List<NewsBrands>> {
  @override
  List<NewsBrands> build() {
    return allBrands;
  }

  // set isSelected property to true for the selected brand
  void updateBrand(NewsBrands brand) {
    final index = state.indexOf(brand);
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          NewsBrands(name: state[i].name, isSelected: true)
        else
          NewsBrands(name: state[i].name, isSelected: false)
    ];
  }
}

final newsBrandsProvider = Provider((ref) {
  return allBrands;
});

final selectedBrandsNameProvider = Provider((ref) {
  final brands = ref.watch(newsBrandsNotifierProvider);
  final selectedBrands = brands.where((brand) => brand.isSelected).toList();
  return selectedBrands.map((brand) => brand.name.toString()).toList();
});

// notifier that changes isSelected property
final newsBrandsNotifierProvider =
    NotifierProvider<NewsBrandNotifier, List<NewsBrands>>(() {
  return NewsBrandNotifier();
});
