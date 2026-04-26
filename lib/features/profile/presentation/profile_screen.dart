import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/supabase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final fullName = user?.userMetadata['full_name'] as String? ?? 'Guest';
    final email = user?.email ?? 'Not signed in';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.md,
                AppSizes.lg,
                AppSizes.lg,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(email,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSizes.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_rounded,
                                  color: AppColors.accent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Wanderer',
                                style: TextStyle(
                                  color: AppColors.accentDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Row(
                  children: [
                    _Stat(label: 'Trips', value: '0'),
                    _Divider(),
                    _Stat(label: 'XP', value: '0'),
                    _Divider(),
                    _Stat(label: 'Rewards', value: '0'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Menu sections
            _Section(
              title: 'Account',
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal information',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: 'Travel documents',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.payment_rounded,
                  label: 'Payment methods',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Preferences',
                  onTap: () {},
                ),
              ],
            ),
            _Section(
              title: 'Tafiya',
              items: [
                _MenuItem(
                  icon: Icons.tour_rounded,
                  label: 'Become a guide',
                  badge: 'Earn',
                  onTap: () => context.push(AppRoutes.guideEnrollment),
                ),
                _MenuItem(
                  icon: Icons.business_center_outlined,
                  label: 'List your tours (Operator)',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Refer & earn',
                  onTap: () {},
                ),
              ],
            ),
            _Section(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help center',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.policy_outlined,
                  label: 'Terms & privacy',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  isDestructive: true,
                  onTap: () async {
                    await ref.read(supabaseClientProvider).auth.signOut();
                    ref.read(currentUserProvider.notifier).state = null;
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.divider);
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.sm,
              bottom: AppSizes.sm,
            ),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: items.map((item) {
                final isLast = items.indexOf(item) == items.length - 1;
                return Column(
                  children: [
                    item,
                    if (!isLast)
                      const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: color),
              ),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: AppSizes.sm),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
