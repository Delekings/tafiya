import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class GuideEnrollmentScreen extends ConsumerWidget {
  const GuideEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.25),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 60, AppSizes.lg, AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '💼 SIDE GIG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Become a\nTafiya Guide',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn from your local knowledge',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Join Tafiya\'s network of verified tour guides. Set your own rates, choose your tours, and build a reputation.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Earnings preview
                  Text(
                    'How much you can earn',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: const [
                      Expanded(
                        child: _TierCard(
                          tier: 'Local',
                          rate: '₦15K–30K',
                          unit: 'per day',
                          color: AppColors.primary,
                          icon: Icons.eco_rounded,
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _TierCard(
                          tier: 'Expert',
                          rate: '₦35K–60K',
                          unit: 'per day',
                          color: AppColors.accent,
                          icon: Icons.workspace_premium_rounded,
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _TierCard(
                          tier: 'Master',
                          rate: '₦70K+',
                          unit: 'per day',
                          color: AppColors.primaryDark,
                          icon: Icons.diamond_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // How it works
                  Text(
                    'How it works',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const _Step(
                    number: '1',
                    title: 'Apply & verify',
                    body:
                        'Submit your NIN, BVN, ID, and references. Pass our knowledge assessment.',
                  ),
                  const _Step(
                    number: '2',
                    title: 'Train & certify',
                    body:
                        'Complete safety training and a trial tour with one of our reviewers.',
                  ),
                  const _Step(
                    number: '3',
                    title: 'Get bookings',
                    body:
                        'Travelers and operators hire you. You can also create your own mini-tours.',
                  ),
                  const _Step(
                    number: '4',
                    title: 'Get paid weekly',
                    body:
                        'Tafiya holds payments in escrow and releases them to you after each tour.',
                    isLast: true,
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Requirements
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who can apply?',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        const _Bullet(
                            text: 'Nigerian citizens, 21+ years old'),
                        const _Bullet(
                            text:
                                'Strong knowledge of at least one Nigerian destination'),
                        const _Bullet(
                            text: 'Fluent in English (other languages a plus)'),
                        const _Bullet(text: 'Smartphone with camera'),
                        const _Bullet(
                            text: 'Valid government-issued ID & NIN'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting application...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: const Text('Start My Application'),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Center(
                    child: Text(
                      'Application takes about 10 minutes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String tier;
  final String rate;
  final String unit;
  final Color color;
  final IconData icon;
  const _TierCard({
    required this.tier,
    required this.rate,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            tier,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            rate,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool isLast;
  const _Step({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(body,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    )),
          ),
        ],
      ),
    );
  }
}
