import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/operator_repository.dart';

class CreateTourScreen extends ConsumerStatefulWidget {
  const CreateTourScreen({super.key});

  @override
  ConsumerState<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends ConsumerState<CreateTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destController = TextEditingController();
  final _countryController = TextEditingController(text: 'Nigeria');
  final _coverController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  final _descController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _includedController = TextEditingController();
  final _excludedController = TextEditingController();

  String _currency = 'NGN';
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 35));
  bool _publish = true;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    _countryController.dispose();
    _coverController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    _descController.dispose();
    _highlightsController.dispose();
    _includedController.dispose();
    _excludedController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          _startDate = result;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = result;
        }
      });
    }
  }

  List<String> _splitLines(String input) =>
      input.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(operatorRepositoryProvider).createTour(
        title: _titleController.text.trim(),
        destination: _destController.text.trim(),
        country: _countryController.text.trim(),
        coverImage: _coverController.text.trim(),
        pricePerPerson:
        double.parse(_priceController.text.replaceAll(',', '')),
        currency: _currency,
        startDate: _startDate,
        endDate: _endDate,
        totalSlots: int.parse(_slotsController.text),
        categories: const ['group'],
        isInternational: _countryController.text.trim().toLowerCase() !=
            'nigeria',
        highlights: _splitLines(_highlightsController.text),
        included: _splitLines(_includedController.text),
        excluded: _splitLines(_excludedController.text),
        description: _descController.text.trim(),
        isPublished: _publish,
      );
      ref.invalidate(myToursProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_publish ? 'Tour published!' : 'Tour saved as draft.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Tour'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('Basics'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tour title *',
                    hintText: 'e.g. Lagos Detty December',
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _destController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Destination *',
                          hintText: 'Lagos',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Destination required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: TextFormField(
                        controller: _countryController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Country *'),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Country required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _coverController,
                  decoration: const InputDecoration(
                    labelText: 'Cover image URL *',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Cover image required' : null,
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionLabel('Pricing & Slots'),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price per person *',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v.replaceAll(',', '')) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(labelText: 'Currency'),
                        items: const [
                          DropdownMenuItem(value: 'NGN', child: Text('NGN')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                        ],
                        onChanged: (v) => setState(() => _currency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _slotsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total slots *',
                    hintText: 'e.g. 20',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionLabel('Dates'),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start date',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(dateFmt.format(_startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End date',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(dateFmt.format(_endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionLabel('Description'),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'About this tour',
                    hintText: 'What should travelers expect?',
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _highlightsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Highlights (one per line)',
                    hintText: 'VIP party access\nBeach day\nEmir\'s palace tour',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _includedController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What\'s included (one per line)',
                    hintText: 'Hotel\nMeals\nAirport pickup',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _excludedController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not included (one per line)',
                    hintText: 'Flights\nVisa fees',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish immediately'),
                  subtitle: Text(
                    _publish
                        ? 'Visible to travelers right away'
                        : 'Saved as a private draft',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: _publish,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _publish = v),
                ),
                const SizedBox(height: AppSizes.lg),
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
                      : Text(_publish ? 'Publish Tour' : 'Save as Draft'),
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: AppSizes.sm, top: AppSizes.sm),
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