import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/providers/news_brands_provider.dart';

import '../models/article_model.dart';

const List<Article> allArticles = [
  Article(
    id: 1,
    newsBrand: "The Herald",
    title: "Zimbabwe to receive 2.5 million doses of Covid-19 vaccines",
    author: "Thomas",
    article:
        "Zimbabwe is set to receive 2.5 million doses of Covid-19 vaccines from China.",
    date: "1 June 2021",
    imageUrl: "assets/images/herald.png",
    isBookmarked: false,
  ),
  Article(
    id: 2,
    newsBrand: "The Chronicle",
    title: "Zimbabwe to receive 2.5 million doses of Covid-19 vaccines",
    author: "John",
    article:
        "Zimbabwe is set to receive 2.5 million doses of Covid-19 vaccines from China.",
    date: "1 June 2021",
    imageUrl: "assets/images/chronicle.png",
    isBookmarked: true,
  ),
  Article(
    id: 3,
    newsBrand: "The Sunday Mail",
    title:
        "Government launches vaccination campaign amidst rising Covid-19 cases",
    author: "Emily",
    article:
        "The Zimbabwean government has launched a nationwide vaccination campaign in response to the rising number of Covid-19 cases.",
    date: "5 June 2021",
    imageUrl: "assets/images/sunday.png",
    isBookmarked: false,
  ),
  Article(
    id: 4,
    newsBrand: "NewsDay",
    title: "Health experts urge public to get vaccinated as third wave looms",
    author: "Michael",
    article:
        "Health experts in Zimbabwe are urging the public to get vaccinated as the country braces for a potential third wave of Covid-19 infections.",
    date: "10 June 2021",
    imageUrl: "assets/images/newsday.png",
    isBookmarked: false,
  ),
  Article(
    id: 5,
    newsBrand: "The Financial Gazzette",
    title: "Government announces plans for vaccine distribution",
    author: "Grace",
    article:
        "The Zimbabwean government has announced plans for the distribution of Covid-19 vaccines across the country, prioritizing high-risk groups.",
    date: "15 June 2021",
    imageUrl: "assets/images/gazzete.jpg",
    isBookmarked: false,
  ),
  Article(
    id: 6,
    newsBrand: "Zimbabwe Independent",
    title: "Zimbabwe receives additional vaccine doses from COVAX initiative",
    author: "Daniel",
    article:
        "Zimbabwe has received an additional batch of Covid-19 vaccine doses through the COVAX initiative, bolstering the country's vaccination efforts.",
    date: "20 June 2021",
    imageUrl: "assets/images/independent.png",
    isBookmarked: false,
  ),
  Article(
    id: 7,
    newsBrand: "The Zimbabwean",
    title: "Public urged to remain vigilant despite vaccine rollout",
    author: "Sophia",
    article:
        "Despite the rollout of Covid-19 vaccines, health authorities in Zimbabwe are urging the public to remain vigilant and adhere to safety measures to prevent further spread of the virus.",
    date: "25 June 2021",
    imageUrl: "assets/images/zimbabwean.png",
    isBookmarked: false,
  ),
  Article(
    id: 8,
    newsBrand: "Daily News",
    title: "Zimbabwe surpasses vaccination target for first phase",
    author: "Jacob",
    article:
        "Zimbabwe has surpassed its vaccination target for the first phase of the immunization campaign, with health officials expressing optimism about the progress.",
    date: "30 June 2021",
    imageUrl: "assets/images/dailynews.png",
    isBookmarked: false,
  ),
  Article(
    id: 9,
    newsBrand: "The Herald",
    title: "Concerns raised over vaccine hesitancy in rural areas",
    author: "Olivia",
    article:
        "Health authorities in Zimbabwe have raised concerns over vaccine hesitancy in rural areas, emphasizing the importance of education and awareness campaigns.",
    date: "5 July 2021",
    imageUrl: "assets/images/herald.png",
    isBookmarked: false,
  ),
  Article(
    id: 10,
    newsBrand: "The Chronicle",
    title:
        "Zimbabwe launches mobile vaccination clinics to reach remote communities",
    author: "Nathan",
    article:
        "The Zimbabwean government has launched mobile vaccination clinics to reach remote communities, aiming to ensure equitable access to Covid-19 vaccines.",
    date: "10 July 2021",
    imageUrl: "assets/images/chronicle.png",
    isBookmarked: false,
  ),
  Article(
    id: 11,
    newsBrand: "The Sunday Mail",
    title:
        "Zimbabwean authorities collaborate with WHO on vaccine distribution strategy",
    author: "Emma",
    article:
        "Zimbabwean health authorities are collaborating with the World Health Organization (WHO) to develop a comprehensive vaccine distribution strategy, aimed at reaching all segments of the population.",
    date: "15 July 2021",
    imageUrl: "assets/images/sunday.png",
    isBookmarked: false,
  ),
  Article(
    id: 12,
    newsBrand: "NewsDay",
    title:
        "Zimbabwean scientists explore indigenous remedies alongside vaccination efforts",
    author: "David",
    article:
        "Scientists in Zimbabwe are exploring the potential of indigenous remedies alongside vaccination efforts, drawing on traditional knowledge to combat Covid-19.",
    date: "20 July 2021",
    imageUrl: "assets/images/newsday.png",
    isBookmarked: false,
  ),
];

final allArticlesProvider = Provider((ref) {
  return allArticles;
});

final selectedBrandsArticlesProvider = Provider((ref) {
  final currentBrand = ref.watch(selectedBrandsNameProvider).first;
  return allArticles.where((brand) => brand.newsBrand == currentBrand).toList();
});
