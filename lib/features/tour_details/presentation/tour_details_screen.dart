import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../core/router/app_router.dart';

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
    final formatter = NumberFormat.currency(
      symbol: tour.currency == 'NGN' ? '₦' : '\$',
      decimalDigits: 0,
    );

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ... all your existing slivers, UNCHANGED ...
            // (the SliverAppBar with hero image, and the SliverToBoxAdapter
            //  with the tour body — leave them exactly as they are)
          ],
        ),
        // Sticky bottom CTA
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.lg,
              AppSizes.md + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'From',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${formatter.format(tour.pricePerPerson)} / person',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: tour.isFull
                        ? null
                        : () => context.push('/booking/${tour.id}'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 56),
                    ),
                    child: Text(tour.isFull ? 'Sold Out' : 'Book Now'),
                  ),
                ],
              ),
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
