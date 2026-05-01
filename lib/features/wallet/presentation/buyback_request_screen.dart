import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/points_repository.dart';
import '../../../data/services/supabase_service.dart';

class BuybackRequestScreen extends ConsumerStatefulWidget {
  const BuybackRequestScreen({super.key});

  @override
  ConsumerState<BuybackRequestScreen> createState() =>
      _BuybackRequestScreenState();
}

class _BuybackRequestScreenState extends ConsumerState<BuybackRequestScreen> {
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankController = TextEditingController();

  bool _submitting = false;

  static const int minThreshold = 50000;

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  int? _parseAmount() {
    return int.tryParse(_amountController.text.replaceAll(',', ''));
  }

  Future<void> _submit() async {
    final amount = _parseAmount();
    if (amount == null || amount < minThreshold) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum buyback is ${NumberFormat.decimalPattern().format(minThreshold)} points',
          ),
        ),
      );
      return;
    }

    final balance = ref.read(pointBalanceProvider).valueOrNull;
    if (balance == null || balance.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    if (_accountNumberController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid account number')),
      );
      return;
    }

    if (_accountNameController.text.trim().isEmpty ||
        _bankController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All bank fields are required')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      final payout = (amount * 0.9).floor();

      // Insert buyback request
      await client.from('point_buyback_requests').insert({
        'user_id': user.id,
        'points_amount': amount,
        'naira_payout': payout,
        'bank_account_number': _accountNumberController.text.trim(),
        'bank_name': _bankController.text.trim(),
        'account_name': _accountNameController.text.trim(),
      });

      // Debit points immediately (held while request is pending)
      await client.rpc('award_points', params: {
        'p_user_id': user.id,
        'p_amount': -amount,
        'p_type': 'buyback',
        'p_description':
        'Buyback request — ₦${NumberFormat.decimalPattern().format(payout)} payout pending',
      });

      ref.invalidate(pointBalanceProvider);
      ref.invalidate(pointTransactionsProvider);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Request submitted ✅'),
            content: Text(
              'We\'ll process your buyback within 3-5 business days. ₦${NumberFormat.decimalPattern().format(payout)} will be transferred to your bank.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final fmt = NumberFormat.decimalPattern();
    final amount = _parseAmount() ?? 0;
    final payout = (amount * 0.9).floor();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sell Points Back'),
      ),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (balance) {
          if (!balance.canBuyback) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 56, color: AppColors.textTertiary),
                    const SizedBox(height: AppSizes.md),
                    Text('Not eligible yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Buyback unlocks at ${fmt.format(minThreshold)} points. You have ${fmt.format(balance.balance)}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  children: [
                    // Eligibility card
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'You\'re eligible',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${fmt.format(balance.balance)} points available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // How it works
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How it works',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSizes.sm),
                          const _InfoLine(
                            text: 'Min 50,000 points per request',
                          ),
                          const _InfoLine(
                            text: 'Tafiya pays 90% of point value (10% retention fee)',
                          ),
                          const _InfoLine(
                            text: 'Payout to your Nigerian bank in 3–5 business days',
                          ),
                          const _InfoLine(
                            text: 'Points are held when you submit, refunded if rejected',
                          ),
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
                      decoration: InputDecoration(
                        labelText: 'Points to sell',
                        hintText: 'e.g. ${fmt.format(50000)}',
                        prefixIcon: const Icon(Icons.stars_rounded),
                        suffixText: 'pts',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    if (amount >= minThreshold) ...[
                      const SizedBox(height: AppSizes.md),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You\'ll receive',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₦${fmt.format(payout)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '10% fee',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '−₦${fmt.format(amount - payout)}',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.lg),

                    Text('Bank Details',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: _accountNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Account name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Account number',
                        hintText: '0123456789',
                        prefixIcon: Icon(Icons.numbers_rounded),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextField(
                      controller: _bankController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Bank name',
                        hintText: 'e.g. GTBank',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                    ),
                  ],
                ),
              ),
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
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: _submitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Submit Request'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String text;
  const _InfoLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 4, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}