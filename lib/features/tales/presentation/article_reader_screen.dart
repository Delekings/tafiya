import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/articles_repository.dart';
import '../../../data/repositories/tour_repository.dart';

class ArticleReaderScreen extends ConsumerWidget {
  final String slug;
  const ArticleReaderScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleBySlugProvider(slug));

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (article) {
          if (article == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: AppSizes.sm),
                  const Text('Article not found'),
                  const SizedBox(height: AppSizes.md),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }
          return _ArticleBody(article: article);
        },
      ),
    );
  }
}

class _ArticleBody extends ConsumerWidget {
  final Article article;
  const _ArticleBody({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Hero image with back button
        SliverAppBar(
          expandedHeight: 360,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.share_rounded,
                      color: AppColors.textPrimary, size: 20),
                  onPressed: () {},
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
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
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Article content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.kicker != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.kicker!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    height: 1.15,
                  ),
                ),
                if (article.excerpt != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    article.excerpt!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.lg),

                // Author + read time
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      backgroundImage: article.authorAvatar != null
                          ? NetworkImage(article.authorAvatar!)
                          : null,
                      child: article.authorAvatar == null
                          ? Text(
                        article.authorName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.authorName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${DateFormat('MMM d, yyyy').format(article.createdAt)} · ${article.readMinutes} min read',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),
                const Divider(),
                const SizedBox(height: AppSizes.md),

                // Body — simple markdown rendering
                _MarkdownBody(text: article.body),

                const SizedBox(height: AppSizes.xl),

                // Related tour CTA
                if (article.relatedTourId != null)
                  _RelatedTourCard(tourId: article.relatedTourId!)
                else if (article.relatedDestination != null)
                  _ExploreCTA(destination: article.relatedDestination!),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================
// Lightweight markdown renderer
// Supports: ## headers, **bold**, *italic*, paragraphs
// =============================================
class _MarkdownBody extends StatelessWidget {
  final String text;
  const _MarkdownBody({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = text.trim().split(RegExp(r'\n\s*\n'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        final trimmed = block.trim();

        // Header (## Heading)
        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(
                top: AppSizes.lg, bottom: AppSizes.sm),
            child: Text(
              trimmed.substring(3),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }

        // Bullet list (lines starting with -)
        if (trimmed.startsWith('- ')) {
          final items = trimmed
              .split('\n')
              .where((l) => l.trim().startsWith('- '))
              .map((l) => l.trim().substring(2))
              .toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(Icons.circle,
                          size: 6, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InlineRichText(text: item),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
          );
        }

        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: _InlineRichText(text: trimmed),
        );
      }).toList(),
    );
  }
}

/// Renders text with inline **bold** and *italic* formatting.
class _InlineRichText extends StatelessWidget {
  final String text;
  const _InlineRichText({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final m = match.group(0)!;
      if (m.startsWith('**')) {
        spans.add(TextSpan(
          text: m.substring(2, m.length - 2),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else {
        spans.add(TextSpan(
          text: m.substring(1, m.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.7,
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        children: spans,
      ),
    );
  }
}

// =============================================
// Related tour CTA — pulls live tour data
// =============================================
class _RelatedTourCard extends ConsumerWidget {
  final String tourId;
  const _RelatedTourCard({required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourByIdProvider(tourId));
    return tourAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (tour) {
        if (tour == null) return const SizedBox();
        return InkWell(
          onTap: () => context.push('/tour/:id'),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want to walk this story?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  tour.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  '${tour.destination}, ${tour.country} · ${tour.durationDays} days',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Book this experience',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExploreCTA extends StatelessWidget {
  final String destination;
  const _ExploreCTA({required this.destination});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/discover'),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.explore_rounded, color: AppColors.primary),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore $destination',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'See available tours',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}