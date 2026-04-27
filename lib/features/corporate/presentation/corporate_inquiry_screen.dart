import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/supabase_service.dart';

class CorporateInquiryScreen extends ConsumerStatefulWidget {
  const CorporateInquiryScreen({super.key});

  @override
  ConsumerState<CorporateInquiryScreen> createState() =>
      _CorporateInquiryScreenState();
}

class _CorporateInquiryScreenState
    extends ConsumerState<CorporateInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _groupSizeController = TextEditingController();
  final _datesController = TextEditingController();
  final _destinationController = TextEditingController();
  final _messageController = TextEditingController();
  String _budget = '₦1M – ₦5M';
  bool _loading = false;
  bool _submitted = false;

  static const _budgetOptions = [
    'Under ₦1M',
    '₦1M – ₦5M',
    '₦5M – ₦20M',
    '₦20M+',
    'Not sure yet',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _emailController.text = user.email ?? '';
      final name = user.userMetadata?['full_name'] as String?;
      if (name != null) _contactNameController.text = name;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _groupSizeController.dispose();
    _datesController.dispose();
    _destinationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      await client.from('corporate_inquiries').insert({
        'user_id': user?.id,
        'company_name': _companyController.text.trim(),
        'contact_name': _contactNameController.text.trim(),
        'contact_email': _emailController.text.trim(),
        'contact_phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'group_size': int.tryParse(_groupSizeController.text.trim()),
        'preferred_dates': _datesController.text.trim().isEmpty
            ? null
            : _datesController.text.trim(),
        'budget_range': _budget,
        'destination_preference': _destinationController.text.trim().isEmpty
            ? null
            : _destinationController.text.trim(),
        'message': _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      });
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Corporate Travel'),
      ),
      body: SafeArea(
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 44),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Thank you!',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Your inquiry is in. A Tafiya travel specialist will reach out within 24 hours to plan something extraordinary for your team.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💼',
                      style: TextStyle(fontSize: 28)),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Plan a corporate trip',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Retreats, off-sites, team incentives. Tell us what you have in mind — we\'ll come back with a tailored proposal.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            _SectionLabel('Your company'),
            TextFormField(
              controller: _companyController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Company name *',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _contactNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Work email *',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+234...',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _SectionLabel('Trip details'),
            TextFormField(
              controller: _groupSizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Group size (estimated)',
                prefixIcon: Icon(Icons.groups_2_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _datesController,
              decoration: const InputDecoration(
                labelText: 'Preferred dates',
                hintText: 'e.g. Late September 2026',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination preference',
                hintText: 'e.g. Obudu, Zanzibar, surprise us',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<String>(
              value: _budget,
              decoration: const InputDecoration(
                labelText: 'Budget range',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              items: _budgetOptions
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _budget = v ?? _budget),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Anything else?',
                hintText: 'Goals for the trip, special requests, etc.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white,
                ),
              )
                  : const Text('Submit Inquiry'),
            ),
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Text(
                'A specialist will be in touch within 24 hours.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}