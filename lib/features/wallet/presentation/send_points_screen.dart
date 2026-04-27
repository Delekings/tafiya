import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/points_repository.dart';
import '../../../data/services/supabase_service.dart';

class SendPointsScreen extends ConsumerStatefulWidget {
  const SendPointsScreen({super.key});

  @override
  ConsumerState<SendPointsScreen> createState() => _SendPointsScreenState();
}

class _SendPointsScreenState extends ConsumerState<SendPointsScreen> {
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _foundUser;
  String? _searchError;

  static const int maxPerGift = 50000;

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _findRecipient() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _foundUser = null;
        _searchError = 'Enter a valid email';
      });
      return;
    }
    setState(() {
      _loading = true;
      _searchError = null;
      _foundUser = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      final me = client.auth.currentUser;
      final res = await client
          .from('profiles')
          .select('id, email, full_name')
          .eq('email', email)
          .maybeSingle();
      if (res == null) {
        setState(() => _searchError = 'No Tafiya user with that email');
      } else if (res['id'] == me?.id) {
        setState(() => _searchError = 'You can\'t send points to yourself');
      } else {
        setState(() => _foundUser = res as Map<String, dynamic>);
      }
    } catch (e) {
      setState(() => _searchError = 'Search failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    if (_foundUser == null) return;
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    if (amount > maxPerGift) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max ₦${NumberFormat.decimalPattern().format(maxPerGift)} per gift')),
      );
      return;
    }

    final balance = ref.read(pointBalanceProvider).valueOrNull;
    if (balance != null && balance.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final me = client.auth.currentUser!;

      // Debit sender
      await client.rpc('award_points', params: {
        'p_user_id': me.id,
        'p_amount': -amount,
        'p_type': 'gift_sent',
        'p_description':
        'Sent to ${_foundUser!['full_name'] ?? _foundUser!['email']}',
        'p_related_user_id': _foundUser!['id'],
      });

      // Credit recipient
      await client.rpc('award_points', params: {
        'p_user_id': _foundUser!['id'],
        'p_amount': amount,
        'p_type': 'gift_received',
        'p_description': _noteController.text.trim().isEmpty
            ? 'Gift from a friend'
            : _noteController.text.trim(),
        'p_related_user_id': me.id,
      });

      // Log gift record
      await client.from('point_gifts').insert({
        'sender_id': me.id,
        'recipient_id': _foundUser!['id'],
        'amount': amount,
        'note': _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        'redeemable_after':
        DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      ref.invalidate(pointBalanceProvider);
      ref.invalidate(pointTransactionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🎁 Sent ${NumberFormat.decimalPattern().format(amount)} points!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final fmt = NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Send Points'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance
              balanceAsync.maybeWhen(
                data: (b) => Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: AppSizes.sm),
                      Text('Available: ${fmt.format(b.balance)} pts',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Recipient',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Recipient email',
                        hintText: 'friend@example.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  IconButton.filled(
                    onPressed: _loading ? null : _findRecipient,
                    icon: const Icon(Icons.search_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
              if (_searchError != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(_searchError!,
                    style: const TextStyle(color: AppColors.error)),
              ],
              if (_foundUser != null) ...[
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border:
                    Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          ((_foundUser!['full_name'] as String?) ??
                              (_foundUser!['email'] as String))[0]
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _foundUser!['full_name'] as String? ??
                                  'Tafiya member',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _foundUser!['email'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('Amount',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Points to send',
                    hintText: 'e.g. 5,000',
                    prefixIcon: Icon(Icons.stars_rounded),
                    suffixText: 'pts',
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Max ₦${fmt.format(maxPerGift)} per gift, ₦200,000 per month total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'Happy birthday! 🎉',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                ElevatedButton(
                  onPressed: _loading ? null : _send,
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white,
                    ),
                  )
                      : const Text('Send Points'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}