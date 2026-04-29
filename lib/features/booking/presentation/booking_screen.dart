import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/points_repository.dart';
import '../../../core/router/app_router.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String tourId;
  const BookingScreen({super.key, required this.tourId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _paymentPlan = 'full';
  int _installmentMonths = 3;
  int _travelers = 1;
  bool _confirming = false;

  Future<void> _confirmBooking(
      dynamic tour,
      double total,
      double firstPayment,
      ) async {
    setState(() => _confirming = true);
    try {
      final bookingId =
      await ref.read(bookingRepositoryProvider).createBooking(
        tourId: tour.id,
        travelers: _travelers,
        totalAmount: total,
        paymentPlan: _paymentPlan,
        installmentMonths:
        _paymentPlan == 'installment' ? _installmentMonths : 0,
        amountPaid: firstPayment,
        pointsUsed: 0,
      );

      ref.invalidate(pointBalanceProvider);
      ref.invalidate(pointTransactionsProvider);
      ref.invalidate(myBookingsProvider);
      ref.invalidate(allToursProvider);
      ref.invalidate(featuredToursProvider);
      ref.invalidate(trendingToursProvider);
      ref.invalidate(tourByIdProvider(tour.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tour.currency == 'NGN'
                  ? 'Booking confirmed! 🎉 Cashback added to your wallet.'
                  : 'Booking confirmed! 🎉',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Confirm Booking'),
      ),
      body: tourAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
          }
          return _buildBookingForm(tour);
        },
      ),
    );
  }

  Widget _buildBookingForm(Tour tour) {
    final formatter = NumberFormat.currency(
      symbol: tour.currency == 'NGN' ? '₦' : '\$',
      decimalDigits: 0,
    );
    final total = tour.pricePerPerson * _travelers;
    final monthlyAmount =
        _paymentPlan == 'installment' ? total / _installmentMonths : total;
    final firstPayment = _paymentPlan == 'installment' ? total * 0.3 : total;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tour summary
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          image: DecorationImage(
                            image: NetworkImage(tour.coverImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tour.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('MMM d').format(tour.startDate)} – ${DateFormat('MMM d').format(tour.endDate)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Travelers
                Text(
                  'Travelers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          '$_travelers ${_travelers == 1 ? "traveler" : "travelers"}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: _travelers > 1
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        onPressed: _travelers > 1
                            ? () => setState(() => _travelers--)
                            : null,
                      ),
                      Text(
                        '$_travelers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: AppColors.primary,
                        onPressed: _travelers < tour.slotsRemaining
                            ? () => setState(() => _travelers++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Payment plan
                Text(
                  'Payment Plan',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                _PaymentOption(
                  selected: _paymentPlan == 'full',
                  title: 'Pay in full',
                  subtitle: 'One-time payment',
                  amount: formatter.format(total),
                  badge: 'Save more',
                  onTap: () => setState(() => _paymentPlan = 'full'),
                ),
                const SizedBox(height: AppSizes.sm),
                _PaymentOption(
                  selected: _paymentPlan == 'installment',
                  title: 'Installment plan',
                  subtitle: '30% deposit, then monthly',
                  amount:
                      '${formatter.format(firstPayment)} now + ${formatter.format(monthlyAmount)}/mo',
                  onTap: () =>
                      setState(() => _paymentPlan = 'installment'),
                ),

                if (_paymentPlan == 'installment') ...[
                  const SizedBox(height: AppSizes.md),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spread balance over',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Wrap(
                          spacing: AppSizes.sm,
                          children: [2, 3, 4, 6].map((months) {
                            final selected = _installmentMonths == months;
                            return ChoiceChip(
                              label: Text('$months months'),
                              selected: selected,
                              onSelected: (_) => setState(
                                  () => _installmentMonths = months),
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.lg),

                // Price breakdown
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _PriceRow(
                        label:
                            '${formatter.format(tour.pricePerPerson)} × $_travelers',
                        value: formatter.format(total),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const _PriceRow(label: 'Service fee', value: 'Free'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                        child: Divider(),
                      ),
                      _PriceRow(
                        label: 'Total',
                        value: formatter.format(total),
                        emphasized: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Escrow info
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'Your payment is held in escrow. Tafiya releases funds to the operator only after your trip starts.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom CTA bar
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.md + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
                top: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay now',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      formatter.format(firstPayment),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _confirming
                    ? null
                    : () => _confirmBooking(tour, total, firstPayment),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 56),
                ),
                child: _confirming
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Confirm & Pay'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final String amount;
  final String? badge;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      selected ? AppColors.primary : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
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

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style?.copyWith(
            color: emphasized ? AppColors.primary : null,
            fontWeight: emphasized ? FontWeight.w700 : null,
          ),
        ),
      ],
    );
  }
}
