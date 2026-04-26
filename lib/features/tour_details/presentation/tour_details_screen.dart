import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/tour_repository.dart';

class TourDetailsScreen extends ConsumerWidget {
  final String tourId;
  const TourDetailsScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourByIdProvider(tourId));

    return Scaffold(
      body: tourAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
          }
          return _TourDetailsBody(tour: tour);
        },
      ),
    );
  }
}

class _TourDetailsBody extends StatelessWidget {
  final Tour tour;
  const _TourDetailsBody({required this.tour});

  String _formatPrice(double amount) {
    final formatter = NumberFormat.currency(
      symbol: tour.currency == 'NGN' ? '₦' : '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDateRange() {
    final df = DateFormat('MMM d');
    final dfYear = DateFormat('MMM d, yyyy');
    return '${df.format(tour.startDate)} – ${dfYear.format(tour.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero image with back button
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded,
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
                  imageUrl: tour.coverImage,
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & rating
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${tour.destination}, ${tour.country}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${tour.rating} (${tour.reviewCount})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                // Title
                Text(
                  tour.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSizes.lg),
                // Quick facts
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Fact(
                        icon: Icons.calendar_today_rounded,
                        label: 'Dates',
                        value: _formatDateRange(),
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border),
                      _Fact(
                        icon: Icons.schedule_rounded,
                        label: 'Duration',
                        value: '${tour.durationDays} days',
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border),
                      _Fact(
                        icon: Icons.group_rounded,
                        label: 'Slots left',
                        value: '${tour.slotsRemaining}/${tour.totalSlots}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                // Operator
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        tour.operatorName.isNotEmpty ? tour.operatorName[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tour.operatorName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (tour.operatorVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Verified Tour Operator',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md),
                      ),
                      child: const Text('View'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionHeader(title: 'About this tour'),
                const SizedBox(height: AppSizes.sm),
                Text(
                  tour.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionHeader(title: 'Highlights'),
                const SizedBox(height: AppSizes.sm),
                ...tour.highlights.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(h,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                if (tour.included.isNotEmpty) ...[
                  _SectionHeader(title: 'What\'s included'),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: tour.included
                        .map((item) => Chip(
                              label: Text(item),
                              backgroundColor: AppColors.primary
                                  .withOpacity(0.08),
                              labelStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
