import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _supportEmail = 'support@tafiya.app';
  static const _whatsappNumber = '+2348012345678'; // placeholder

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Tafiya Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsapp() async {
    final uri = Uri.parse('https://wa.me/$_whatsappNumber');
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
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(
            'How can we help?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Our team responds within 24 hours on weekdays.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.lg),

          // Email
          _ContactTile(
            icon: Icons.mail_outline_rounded,
            color: AppColors.primary,
            title: 'Email us',
            subtitle: _supportEmail,
            onTap: _openEmail,
          ),

          // WhatsApp
          _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.success,
            title: 'WhatsApp',
            subtitle: 'Chat with our team',
            onTap: _openWhatsapp,
          ),

          const SizedBox(height: AppSizes.xl),

          Text(
            'Common Questions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),

          const _FaqTile(
            question: 'How do bookings work?',
            answer:
            'When you book, your payment is held in escrow. Tafiya only releases funds to the operator after your trip starts, so you\'re protected if anything goes wrong.',
          ),
          const _FaqTile(
            question: 'How do Tafiya Points work?',
            answer:
            '1 point equals ₦1. Earn them through bookings (2% cashback), referrals (5,000 each), reviews (500), and signup bonuses. Spend them on bookings or gift to friends.',
          ),
          const _FaqTile(
            question: 'Can I cancel a booking?',
            answer:
            'Cancellation policies vary by operator. Each tour shows its specific policy. For help with a cancellation, email us with your booking reference.',
          ),
          const _FaqTile(
            question: 'How do referrals work?',
            answer:
            'Share your referral code from the Earn page. When someone signs up with your code AND books their first tour, you both get 5,000 points.',
          ),
          const _FaqTile(
            question: 'How do I become an operator?',
            answer:
            'Tap "Become an operator" from your profile. Fill the form with your business details. We verify within 2-3 business days.',
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppSizes.md, 0, AppSizes.md, AppSizes.md),
          title: Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}