import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/tour_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            'Sannu, $firstName 👋',
                            style: Theme.of(context).textTheme.bodyMedium,
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.lg),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  children: [
                    _CategoryChip(
                      icon: '🏖️',
                      label: 'Beach',
                      bg: const Color(0xFFFEF3E7),
                      onTap: () => context.push('/discover?category=beach'),
                    ),
                    _CategoryChip(
                      icon: '⛰️',
                      label: 'Adventure',
                      bg: const Color(0xFFE7F0E9),
                      onTap: () => context.push('/discover?category=adventure'),
                    ),
                    _CategoryChip(
                      icon: '🏛️',
                      label: 'Cultural',
                      bg: const Color(0xFFF5EAE1),
                      onTap: () => context.push('/discover?category=cultural'),
                    ),
                    _CategoryChip(
                      icon: '🎉',
                      label: 'Festivals',
                      bg: const Color(0xFFFCE7E7),
                      onTap: () => context.push('/discover?category=festivals'),
                    ),
                    _CategoryChip(
                      icon: '💼',
                      label: 'Corporate',
                      bg: const Color(0xFFE7EAF5),
                      onTap: () => context.push('/corporate-inquiry'),
                    ),
                    _CategoryChip(
                      icon: '💕',
                      label: 'Honeymoon',
                      bg: const Color(0xFFFCE7F0),
                      onTap: () => context.push('/discover?category=honeymoon'),
                    ),
                  ],
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
