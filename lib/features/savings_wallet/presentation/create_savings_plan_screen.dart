import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';

class CreateSavingsPlanScreen extends ConsumerStatefulWidget {
  const CreateSavingsPlanScreen({super.key});

  @override
  ConsumerState<CreateSavingsPlanScreen> createState() =>
      _CreateSavingsPlanScreenState();
}

class _CreateSavingsPlanScreenState
    extends ConsumerState<CreateSavingsPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _monthlyController = TextEditingController();
  int _debitDay = 1;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (result != null) setState(() => _targetDate = result);
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Savings plan created! Auto-debit starts next month.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Savings Plan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set your goal',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Save automatically each month toward a specific trip.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSizes.xl),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Plan name',
                    hintText: 'e.g. Dubai July Trip',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name your plan' : null,
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target amount',
                    hintText: '500,000',
                    prefixIcon: Icon(Icons.flag_outlined),
                    prefixText: '₦  ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Set a target';
                    if (double.tryParse(v.replaceAll(',', '')) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _monthlyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly contribution',
                    hintText: '50,000',
                    prefixIcon: Icon(Icons.event_repeat_rounded),
                    prefixText: '₦  ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Set monthly amount';
                    if (double.tryParse(v.replaceAll(',', '')) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target date',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(_targetDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Auto-debit day each month',
                    prefixIcon: Icon(Icons.event_rounded),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _debitDay,
                      isExpanded: true,
                      items: List.generate(28, (i) => i + 1)
                          .map((day) => DropdownMenuItem(
                                value: day,
                                child: Text(
                                  'Day $day of every month',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _debitDay = v ?? _debitDay),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          '5% penalty if you withdraw before reaching your goal. No fee when funds go toward bookings.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                ElevatedButton(
                  onPressed: _create,
                  child: const Text('Activate Auto-Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
