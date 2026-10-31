import 'package:news_app/domain/models/news_source.dart';

/// Newspapers with a working public RSS feed, in the order their chips
/// appear. When a story is in more than one paper's feed it is credited to
/// the first paper in this list.
///
/// The Zimpapers titles (The Herald, The Chronicle, The Sunday Mail) share
/// heraldonline.co.zw, so each uses its own category feed; the site-wide
/// feed mixes all of them together.
///
/// NewsDay is not included: its site answers automated requests with a
/// browser challenge, which the app respects rather than works around.
const newsSources = <NewsSource>[
  NewsSource(
    id: 'herald',
    name: 'The Herald',
    feedUrl: 'https://www.heraldonline.co.zw/category/herald/feed/',
    logoAsset: 'assets/images/herald.png',
  ),
  NewsSource(
    id: 'chronicle',
    name: 'The Chronicle',
    feedUrl: 'https://www.heraldonline.co.zw/category/chronicle/feed/',
    logoAsset: 'assets/images/chronicle.png',
  ),
  NewsSource(
    id: 'sundaymail',
    name: 'The Sunday Mail',
    feedUrl: 'https://www.heraldonline.co.zw/category/sundaymail/feed/',
    logoAsset: 'assets/images/sunday.png',
  ),
  NewsSource(
    id: 'dailynews',
    name: 'Daily News',
    feedUrl: 'https://dailynews.co.zw/feed/',
    logoAsset: 'assets/images/dailynews.png',
  ),
  NewsSource(
    id: 'independent',
    name: 'Zimbabwe Independent',
    feedUrl: 'https://theindependent.co.zw/feed/',
    logoAsset: 'assets/images/independent.png',
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
