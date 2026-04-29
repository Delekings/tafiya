import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/articles_repository.dart';

class TalesScreen extends ConsumerStatefulWidget {
  const TalesScreen({super.key});

  @override
  ConsumerState<TalesScreen> createState() => _TalesScreenState();
}

class _TalesScreenState extends ConsumerState<TalesScreen> {
  String _selectedCategory = 'all';

  static const _categories = [
    {'value': 'all', 'label': 'All'},
    {'value': 'culture', 'label': 'Culture'},
    {'value': 'destination', 'label': 'Destinations'},
    {'value': 'practical', 'label': 'Practical'},
    {'value': 'diaspora', 'label': 'Diaspora'},
  ];

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(allArticlesProvider);
    final featuredAsync = ref.watch(featuredArticlesProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(allArticlesProvider);
          ref.invalidate(featuredArticlesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tafiya Tales',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stories that move you. History, places, voices.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured carousel
            featuredAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 360,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Text('Couldn\'t load: $e'),
                ),
              ),
              data: (featured) {
                if (featured.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox());
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 380,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: featured.length,
                      itemBuilder: (context, index) {
                        final a = featured[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm),
                          child: _FeaturedCard(article: a),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            // Category filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, AppSizes.lg, 0, AppSizes.md),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSizes.sm),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final selected = _selectedCategory == cat['value'];
                      return ChoiceChip(
                        label: Text(cat['label']!),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat['value']!),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Article feed
            articlesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Text('Error: $e'),
                ),
              ),
              data: (articles) {
                final filtered = _selectedCategory == 'all'
                    ? articles
                    : articles
                    .where((a) => a.category == _selectedCategory)
                    .toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book_outlined,
                                size: 48,
                                color: AppColors.textTertiary),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              'No tales in this category yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final a = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
                        child: _ArticleCard(article: a),
                      );
                    },
                    childCount: filtered.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
          ],
        ),
      ),
    );
  }
}

// =============================================
// Featured card (large, in carousel)
// =============================================
class _FeaturedCard extends StatelessWidget {
  final Article article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/tales/${article.slug}'),
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          color: AppColors.surface,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: article.heroImage,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.surfaceVariant),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppSizes.lg,
              right: AppSizes.lg,
              bottom: AppSizes.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.kicker != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.kicker!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Text(
                        article.authorName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' · ${article.readMinutes} min read',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
// Article card (in feed)
// =============================================
class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/tales/${article.slug}'),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: double.infinity,
              child: CachedNetworkImage(
                imageUrl: article.heroImage,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariant),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.categoryLabel.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          article.authorName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          ' · ${article.readMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}