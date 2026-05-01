import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('About Tafiya'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          // Logo / Hero
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Fraunces',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Center(
            child: Text(
              'Tafiya',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          Center(
            child: Text(
              'Your journey, your way.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.xl),

          // Manifesto
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About us',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Tafiya — from the Hausa word for "journey" — is a marketplace built for travelers across Nigeria and the diaspora.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Inspired by the Yoruba ìrìn àjò tradition — where every journey is more than movement, but a passage between worlds — we connect you with verified operators running unforgettable group and solo trips. Detty December in Lagos. Hiking the Obudu plateau. Cultural escapes to Calabar. Beach days in Zanzibar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'We make booking safe with escrow, fair with transparent pricing, and rewarding with our points program. Built in Nigeria, made for the world.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // Links
          _LinkTile(
            icon: Icons.language_rounded,
            label: 'Visit our website',
            onTap: () => _openUrl('https://tafiya.app'),
          ),
          _LinkTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            onTap: () => context.go(AppRoutes.privacyPolicy),
          ),
          _LinkTile(
            icon: Icons.gavel_outlined,
            label: 'Terms of service',
            onTap: () => context.go(AppRoutes.termsOfService),
          ),

          const SizedBox(height: AppSizes.xl),

          // Version
          Center(
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with care in Lagos 🇳🇬',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
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
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.open_in_new_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}