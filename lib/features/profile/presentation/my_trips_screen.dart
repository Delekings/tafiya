import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/booking_repository.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Trips'),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return _EmptyState();
          }

          // Split into upcoming and past
          final now = DateTime.now();
          final upcoming = bookings.where((b) =>
          b.tour != null && b.tour!.endDate.isAfter(now)).toList();
          final past = bookings.where((b) =>
          b.tour != null && b.tour!.endDate.isBefore(now)).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(myBookingsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                if (upcoming.isNotEmpty) ...[
                  Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...upcoming.map((b) => _TripCard(booking: b, isUpcoming: true)),
                  const SizedBox(height: AppSizes.lg),
                ],
                if (past.isNotEmpty) ...[
                  Text(
                    'Past trips',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...past.map((b) => _TripCard(booking: b, isUpcoming: false)),
                ],
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.luggage_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No trips yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Your booked tours will appear here.\nTime to find your next journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Discover tours'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final dynamic booking;
  final bool isUpcoming;
  const _TripCard({required this.booking, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final tour = booking.tour;
    if (tour == null) return const SizedBox();

    final formatter = NumberFormat.currency(
      symbol: tour.currency == 'NGN' ? '₦' : '\$',
      decimalDigits: 0,
    );

    final dateRange =
        '${DateFormat('MMM d').format(tour.startDate)} – ${DateFormat('MMM d, yyyy').format(tour.endDate)}';

    return InkWell(
      onTap: () => context.push('/tour/${tour.id}'),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: tour.coverImage,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.surfaceVariant),
                  ),
                  // Status badge
                  Positioned(
                    top: AppSizes.sm,
                    left: AppSizes.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? AppColors.success
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUpcoming
                                ? Icons.flight_takeoff_rounded
                                : Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUpcoming ? 'Upcoming' : 'Completed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${tour.destination}, ${tour.country}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Dates
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        dateRange,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Divider(),
                  ),

                  // Footer row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total paid',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            formatter.format(booking.totalAmount),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_rounded,
                                size: 13, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.travelers} ${booking.travelers == 1 ? "traveler" : "travelers"}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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