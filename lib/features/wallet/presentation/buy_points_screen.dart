import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/points_repository.dart';
import '../../../data/services/supabase_service.dart';

class BuyPointsScreen extends ConsumerStatefulWidget {
  const BuyPointsScreen({super.key});

  @override
  ConsumerState<BuyPointsScreen> createState() => _BuyPointsScreenState();
}

class _BuyPointsScreenState extends ConsumerState<BuyPointsScreen> {
  int? _selectedPackage;
  bool _loading = false;

  static const _packages = [
    {'points': 5000, 'naira': 5000, 'badge': null},
    {'points': 10000, 'naira': 10000, 'badge': null},
    {'points': 25000, 'naira': 25000, 'badge': 'Popular'},
    {'points': 50000, 'naira': 50000, 'badge': null},
    {'points': 100000, 'naira': 100000, 'badge': 'Best value'},
    {'points': 250000, 'naira': 250000, 'badge': null},
  ];

  Future<void> _confirmPurchase() async {
    if (_selectedPackage == null) return;
    final pkg = _packages[_selectedPackage!];
    setState(() => _loading = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      // For now, simulate purchase — real Paystack flow comes later.
      // In production this would: 1) create paystack ref, 2) launch checkout,
      // 3) verify webhook, 4) credit points server-side.
      await client.from('point_purchases').insert({
        'user_id': user.id,
        'points_amount': pkg['points'],
        'naira_amount': pkg['naira'],
        'paystack_reference': 'demo_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      });

      // Credit points + log transaction via the SQL function
      await client.rpc('award_points', params: {
        'p_user_id': user.id,
        'p_amount': pkg['points'],
        'p_type': 'purchase',
        'p_description': 'Bought ${NumberFormat.decimalPattern().format(pkg['points'])} points',
      });

      ref.invalidate(pointBalanceProvider);
      ref.invalidate(pointTransactionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🎉 ${NumberFormat.decimalPattern().format(pkg['points'])} points added!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Buy Points'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: [
                  Text(
                    'Choose a package',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1 point = ₦1. Use for bookings or gift to friends.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ...List.generate(_packages.length, (i) {
                    final pkg = _packages[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: _PackageTile(
                        points: pkg['points'] as int,
                        naira: pkg['naira'] as int,
                        badge: pkg['badge'] as String?,
                        selected: _selectedPackage == i,
                        onTap: () => setState(() => _selectedPackage = i),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.lg),
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
                            'Payments processed via Paystack. Points are added instantly upon successful payment.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom CTA
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg, AppSizes.md, AppSizes.lg,
                AppSizes.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: ElevatedButton(
                onPressed: (_selectedPackage == null || _loading)
                    ? null
                    : _confirmPurchase,
                child: _loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white,
                  ),
                )
                    : Text(_selectedPackage == null
                    ? 'Select a package'
                    : 'Pay ₦${fmt.format(_packages[_selectedPackage!]['naira'])}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final int points;
  final int naira;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  const _PackageTile({
    required this.points,
    required this.naira,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
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
                  color: selected ? AppColors.primary : AppColors.textTertiary,
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
                      Text(
                        '${fmt.format(points)} pts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
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
                  Text(
                    '₦${fmt.format(naira)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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