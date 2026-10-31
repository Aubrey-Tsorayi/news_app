import 'package:news_app/domain/models/news_source.dart';

/// Newspapers with a working public RSS feed. NewsDay, The Sunday Mail,
/// The Chronicle and the Zimbabwe Independent are not included yet: their
/// feeds are blocked, empty or unreachable (see Phase 4 of the plan).
const newsSources = <NewsSource>[
  NewsSource(
    id: 'herald',
    name: 'The Herald',
    feedUrl: 'https://www.heraldonline.co.zw/feed/',
    logoAsset: 'assets/images/herald.png',
  ),
  NewsSource(
    id: 'dailynews',
    name: 'Daily News',
    feedUrl: 'https://dailynews.co.zw/feed/',
    logoAsset: 'assets/images/dailynews.png',
  ),
  NewsSource(
    id: 'zimbabwean',
    name: 'The Zimbabwean',
    feedUrl: 'https://www.thezimbabwean.co/feed/',
    logoAsset: 'assets/images/zimbabwean.png',
  ),
  NewsSource(
    id: 'fingaz',
    name: 'Financial Gazette',
    feedUrl: 'https://fingaz.co.zw/feed/',
    logoAsset: 'assets/images/gazzete.jpg',
  ),
];

NewsSource sourceById(String id) =>
    newsSources.firstWhere((s) => s.id == id, orElse: () => newsSources.first);
