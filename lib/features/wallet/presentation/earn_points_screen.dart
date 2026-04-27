import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/points_repository.dart';

class EarnPointsScreen extends ConsumerWidget {
  const EarnPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralCodeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Earn Points'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text('Ways to earn',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Stack up points and use them on bookings or gift to friends.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.lg),

            // Referral card (the hero earn path)
            referralAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox(),
              data: (code) => _ReferralCard(code: code),
            ),

            const SizedBox(height: AppSizes.lg),

            // Other earning paths
            const _EarnTile(
              icon: Icons.replay_rounded,
              color: AppColors.primary,
              title: '2% cashback on bookings',
              body: 'Auto-credited after every booking. Save while you spend.',
              points: 'e.g. ₦200,000 trip = 4,000 pts',
              actionable: false,
            ),
            const _EarnTile(
              icon: Icons.rate_review_outlined,
              color: AppColors.accent,
              title: 'Review your trip',
              body: 'Verified reviews after a tour earn you points.',
              points: '+500 pts per review',
              actionable: false,
            ),
            const _EarnTile(
              icon: Icons.cake_rounded,
              color: AppColors.accentDark,
              title: 'Birthday gift',
              body: 'Set your birthday in profile and get a yearly gift.',
              points: '+2,000 pts on your birthday',
              actionable: false,
            ),
            const _EarnTile(
              icon: Icons.local_fire_department_rounded,
              color: AppColors.warning,
              title: 'Savings streak',
              body: 'Save consistently for 3 months and unlock a bonus.',
              points: '+1,000 pts every 3-month streak',
              actionable: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String? code;
  const _ReferralCard({required this.code});

  Future<void> _copy(BuildContext context) async {
    if (code == null) return;
    final shareText =
        'Join Tafiya and discover Nigeria & beyond! Use my code $code when you sign up: https://tafiya.app';
    await Clipboard.setData(ClipboardData(text: shareText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral link copied!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_add_rounded,
                  color: Colors.white, size: 24),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Refer & Earn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'You and your friend each get 5,000 points when they book their first tour.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Text(
                  code ?? '...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white),
                  onPressed: () => _copy(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share invite link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String points;
  final bool actionable;
  const _EarnTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.points,
    required this.actionable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    points,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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