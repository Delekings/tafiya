import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/tour_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

const _greetings = [
  'Sannu',         // Hausa
  'Bawo ni',       // Yoruba
  'Kedu',          // Igbo
  'Habari',        // Swahili
  'Sawubona',      // Zulu
  'Akwaaba',       // Twi
  'Mbote',         // Lingala
  'Salaam',        // Arabic / Northern Nigeria
  'Mhoro',         // Shona
  'Jambo',         // Swahili (informal)
];

const _categories = [
  {
    'value': 'beach',
    'label': 'Beach',
    'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',
  },
  {
    'value': 'adventure',
    'label': 'Adventure',
    'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
  },
  {
    'value': 'cultural',
    'label': 'Cultural',
    'image': 'https://images.unsplash.com/photo-1604147706283-d7119b5b822c?w=400&q=80',
  },
  {
    'value': 'festivals',
    'label': 'Festivals',
    'image': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400&q=80',
  },
  {
    'value': 'corporate',
    'label': 'Corporate',
    'image': 'https://images.unsplash.com/photo-1573164713988-8665fc963095?w=400&q=80',
  },
  {
    'value': 'honeymoon',
    'label': 'Honeymoon',
    'image': 'https://images.unsplash.com/photo-1542401886-65d6c61db217?w=400&q=80',
  },
];


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = (_greetings.toList()..shuffle()).first;
    final user = ref.watch(currentUserProvider);
    final featured = ref.watch(featuredToursProvider);
    final trending = ref.watch(trendingToursProvider);

    final firstName =
        (user?.userMetadata?['full_name'] as String?)?.split(' ').first ??
            'Traveler';

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(featuredToursProvider);
          ref.invalidate(trendingToursProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Top header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, $firstName 👋',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Where to next?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.textPrimary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.discover),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textTertiary, size: 22),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Search destinations, tours...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Categories
            // const SliverToBoxAdapter(
            //   child: SizedBox(height: AppSizes.lg),
            // ),


            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.lg),
                child: SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSizes.md),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return _CategoryCircle(
                        label: cat['label']!,
                        imageUrl: cat['image']!,
                        onTap: () =>
                            context.go('/discover?category=${cat['value']}'),
                      );
                    },
                  ),
                ),
              ),
            ),



            // Savings CTA banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: _SavingsBanner(
                  onTap: () => context.go(AppRoutes.wallet),
                ),
              ),
            ),

            // Featured section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  0,
                  AppSizes.lg,
                  AppSizes.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Tours',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.discover),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: featured.when(
                loading: () => _buildLoadingCarousel(),
                error: (e, _) => _ErrorView(message: e.toString()),
                data: (tours) => SizedBox(
                  height: 380,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    itemCount: tours.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.md),
                    itemBuilder: (context, index) {
                      final tour = tours[index];
                      return SizedBox(
                        width: 290,
                        child: TourCard(
                          tour: tour,
                          onTap: () => context.push('/tour/${tour.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Trending section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.md,
                ),
                child: Row(
                  children: [
                    Text(
                      'Trending in Nigeria',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),

            // Trending list
            trending.when(
              loading: () => SliverToBoxAdapter(child: _buildLoadingCarousel()),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorView(message: e.toString())),
              data: (tours) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tour = tours[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        0,
                        AppSizes.lg,
                        AppSizes.md,
                      ),
                      child: TourCard(
                        tour: tour,
                        onTap: () => context.push('/tour/${tour.id}'),
                      ),
                    );
                  },
                  childCount: tours.length,
                ),
              ),
            ),

            // Become a guide CTA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: _BecomeGuideBanner(
                  onTap: () => context.push(AppRoutes.guideEnrollment),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCarousel() {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.md),
        itemBuilder: (context, _) => Shimmer.fromColors(
          baseColor: AppColors.surfaceVariant,
          highlightColor: AppColors.background,
          child: Container(
            width: 290,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
class _CategoryCircle extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryCircle({
    required this.label,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceVariant,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color bg;
  final VoidCallback? onTap;
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SavingsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SavingsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(
                Icons.savings_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Save your way to travel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Auto-save monthly toward your dream trip',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _BecomeGuideBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _BecomeGuideBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(
                Icons.tour_rounded,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Become a Tafiya Guide',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Earn extra income sharing your local knowledge',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Couldn\'t load tours',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
