import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/repositories/points_repository.dart';
import '../../../data/services/supabase_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final balanceAsync = ref.watch(pointBalanceProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.xl),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSizes.lg),

          // Profile header card
          profileAsync.when(
            loading: () => _LoadingHeader(),
            error: (e, _) => _LoadingHeader(),
            data: (profile) => _ProfileHeader(
              profile: profile,
              email: user?.email ?? '',
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // Activity section
          const _SectionLabel('ACTIVITY'),
          _MenuTile(
            icon: Icons.luggage_outlined,
            label: 'My Trips',
            subtitle: 'View your bookings',
            onTap: () => context.push(AppRoutes.myTrips),
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Tafiya Points wallet',
            subtitle: balanceAsync.maybeWhen(
              data: (b) =>
              '${NumberFormat.decimalPattern().format(b.balance)} points',
              orElse: () => null,
            ),
            onTap: () => context.go(AppRoutes.wallet),
          ),

          const SizedBox(height: AppSizes.md),

          // Account section
          const _SectionLabel('ACCOUNT'),
          _MenuTile(
            icon: Icons.person_outline,
            label: 'Personal information',
            onTap: () => context.push(AppRoutes.editProfile),
          ),

          // Operator/guide CTAs
          _MenuTile(
            icon: Icons.tour_outlined,
            label: 'Become an operator',
            onTap: () => context.push(AppRoutes.becomeOperator),
          ),

          const SizedBox(height: AppSizes.md),

          // Points section (only if eligible)
          balanceAsync.maybeWhen(
            data: (balance) {
              if (!balance.canBuyback) return const SizedBox();
              return Column(
                children: [
                  const _SectionLabel('POINTS'),
                  _MenuTile(
                    icon: Icons.account_balance_outlined,
                    label: 'Sell points back',
                    subtitle:
                    '${NumberFormat.decimalPattern().format(balance.balance)} pts available',
                    color: AppColors.accent,
                    onTap: () => context.push(AppRoutes.buybackRequest),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              );
            },
            orElse: () => const SizedBox(),
          ),

          // Support section
          const _SectionLabel('SUPPORT'),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () => context.push(AppRoutes.help),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            label: 'About Tafiya',
            onTap: () => context.push(AppRoutes.about),
          ),

          const SizedBox(height: AppSizes.lg),

          // Sign out
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            color: AppColors.error,
            onTap: () async {
              final client = ref.read(supabaseClientProvider);
              await client.auth.signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),

          const SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              'Tafiya v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// Header card
// =============================================
class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final String email;

  const _ProfileHeader({required this.profile, required this.email});

  @override
  Widget build(BuildContext context) {
    final fullName = (profile?['full_name'] as String?) ?? 'Traveler';
    final avatarUrl = profile?['avatar_url'] as String?;
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final referralCode = profile?['referral_code'] as String?;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                      : Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (referralCode != null) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_add_rounded,
                      color: AppColors.accentDark, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Invite code: $referralCode',
                    style: const TextStyle(
                      color: AppColors.accentDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// =============================================
// Menu pieces
// =============================================
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}