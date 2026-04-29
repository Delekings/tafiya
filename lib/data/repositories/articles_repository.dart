import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../services/supabase_service.dart';

class Article {
  final String id;
  final String title;
  final String slug;
  final String heroImage;
  final String? kicker;
  final String? excerpt;
  final String body;
  final String authorName;
  final String? authorAvatar;
  final String category;
  final String? relatedTourId;
  final String? relatedDestination;
  final int readMinutes;
  final bool isFeatured;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.heroImage,
    this.kicker,
    this.excerpt,
    required this.body,
    required this.authorName,
    this.authorAvatar,
    required this.category,
    this.relatedTourId,
    this.relatedDestination,
    required this.readMinutes,
    required this.isFeatured,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      heroImage: json['hero_image'] as String,
      kicker: json['kicker'] as String?,
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String,
      authorName: json['author_name'] as String? ?? 'Tafiya Editors',
      authorAvatar: json['author_avatar'] as String?,
      category: json['category'] as String? ?? 'culture',
      relatedTourId: json['related_tour_id'] as String?,
      relatedDestination: json['related_destination'] as String?,
      readMinutes: (json['read_minutes'] as num?)?.toInt() ?? 5,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Display label for category, e.g. "Cultural Heritage"
  String get categoryLabel {
    switch (category) {
      case 'culture':
        return 'Culture';
      case 'destination':
        return 'Destination';
      case 'practical':
        return 'Practical';
      case 'diaspora':
        return 'Diaspora';
      default:
        return category;
    }
  }
}

class ArticlesRepository {
  final SupabaseClient client;
  ArticlesRepository(this.client);

  Future<List<Article>> getArticles({String? category}) async {
    var query = client
        .from('articles')
        .select()
        .eq('is_published', true);

    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }

    final res = await query.order('created_at', ascending: false);
    return (res as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Article?> getArticleBySlug(String slug) async {
    final res = await client
        .from('articles')
        .select()
        .eq('slug', slug)
        .eq('is_published', true)
        .maybeSingle();
    if (res == null) return null;
    return Article.fromJson(res as Map<String, dynamic>);
  }

  Future<List<Article>> getFeaturedArticles() async {
    final res = await client
        .from('articles')
        .select()
        .eq('is_published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(5);
    return (res as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ArticlesRepository(client);
});

final allArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final repo = ref.watch(articlesRepositoryProvider);
  return repo.getArticles();
});

final featuredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final repo = ref.watch(articlesRepositoryProvider);
  return repo.getFeaturedArticles();
});

final articleBySlugProvider =
FutureProvider.family<Article?, String>((ref, slug) async {
  final repo = ref.watch(articlesRepositoryProvider);
  return repo.getArticleBySlug(slug);
});