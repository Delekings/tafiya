import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/repositories/points_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final txAsync = ref.watch(pointTransactionsProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(pointBalanceProvider);
          ref.invalidate(pointTransactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.xl),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  onPressed: () => _showHowItWorks(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Points card
            balanceAsync.when(
              loading: () => _LoadingCard(),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (balance) => _PointsCard(balance: balance),
            ),

            const SizedBox(height: AppSizes.md),

            // Quick actions row
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.add_rounded,
                    label: 'Buy points',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.buyPoints),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.send_rounded,
                    label: 'Send',
                    color: AppColors.accent,
                    onTap: () => context.push(AppRoutes.sendPoints),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Earn',
                    color: AppColors.primaryLight,
                    onTap: () => context.push(AppRoutes.earnPoints),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Savings section (existing feature, lives here now)
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.savings_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'Trip Savings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.savingsDetail),
                        child: const Text('View →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Auto-save monthly toward a specific trip. Save in Naira, see point equivalents on every contribution.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Recent activity
            Text('Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            txAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Couldn\'t load activity: $e'),
              data: (txs) {
                if (txs.isEmpty) {
                  return _EmptyActivity();
                }
                return Column(
                  children: txs.take(20).map((tx) =>
                      _TransactionTile(transaction: tx)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('How Tafiya Points work',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.md),
            const _InfoRow(
              icon: Icons.swap_horiz_rounded,
              title: '1 Point = ₦1',
              body: 'Simple, predictable. Buy points or earn them through bookings, referrals, and reviews.',
            ),
            const _InfoRow(
              icon: Icons.flight_takeoff_rounded,
              title: 'Spend on bookings',
              body: 'Pay full or partial for any tour using points. No expiry on what you earn.',
            ),
            const _InfoRow(
              icon: Icons.card_giftcard_rounded,
              title: 'Gift to friends',
              body: 'Send points to anyone on Tafiya. Up to ₦50k per gift, ₦200k per month.',
            ),
            const _InfoRow(
              icon: Icons.account_balance_outlined,
              title: 'Sell back at 50k+',
              body: 'Once you have 50,000 points, you can request buyback at 90% of value to your bank.',
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// =============================================
// Sub-widgets
// =============================================

class _PointsCard extends StatelessWidget {
  final PointBalance balance;
  const _PointsCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return Container(
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
          Row(
            children: [
              Icon(Icons.stars_rounded,
                  color: Colors.white.withOpacity(0.85), size: 18),
              const SizedBox(width: 6),
              Text(
                'Tafiya Points',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmt.format(balance.balance),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 44,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'pts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '≈ ₦${fmt.format(balance.balance)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          if (balance.canBuyback)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_outlined,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Eligible for buyback',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PointTransaction transaction;
  const _TransactionTile({required this.transaction});

  IconData get _icon {
    switch (transaction.type) {
      case 'purchase':
        return Icons.add_circle_outline_rounded;
      case 'cashback':
        return Icons.replay_rounded;
      case 'referral':
        return Icons.group_add_rounded;
      case 'review':
        return Icons.rate_review_outlined;
      case 'signup_bonus':
        return Icons.celebration_rounded;
      case 'birthday_bonus':
        return Icons.cake_rounded;
      case 'streak_bonus':
        return Icons.local_fire_department_rounded;
      case 'gift_sent':
        return Icons.send_rounded;
      case 'gift_received':
        return Icons.card_giftcard_rounded;
      case 'booking_redemption':
        return Icons.flight_takeoff_rounded;
      case 'buyback':
        return Icons.account_balance_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String get _typeLabel {
    switch (transaction.type) {
      case 'purchase':
        return 'Bought points';
      case 'cashback':
        return 'Booking cashback';
      case 'referral':
        return 'Referral bonus';
      case 'review':
        return 'Review reward';
      case 'signup_bonus':
        return 'Welcome bonus';
      case 'birthday_bonus':
        return 'Birthday bonus';
      case 'streak_bonus':
        return 'Streak bonus';
      case 'gift_sent':
        return 'Gift sent';
      case 'gift_received':
        return 'Gift received';
      case 'booking_redemption':
        return 'Spent on booking';
      case 'buyback':
        return 'Sold back';
      case 'promotion':
        return 'Promotion';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final isCredit = transaction.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _icon,
              color: isCredit ? AppColors.success : AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                if (transaction.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, h:mm a').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}${fmt.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.success : AppColors.warning,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Text('Couldn\'t load wallet: $message',
          style: const TextStyle(color: AppColors.error)),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              size: 40, color: AppColors.textTertiary),
          const SizedBox(height: AppSizes.sm),
          Text('No activity yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Buy points, refer friends, or book a tour to see activity here.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}