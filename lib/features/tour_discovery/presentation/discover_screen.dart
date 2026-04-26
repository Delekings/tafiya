import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../shared/widgets/tour_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  static const _filters = [
    'All',
    'Nigeria',
    'International',
    'Beach',
    'Cultural',
    'Adventure',
    'Group',
    'Solo',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(allToursProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by destination, theme...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () {},
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          // Filters
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.md),
          // Tour list
          Expanded(
            child: toursAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tours) {
                final query = _searchController.text.toLowerCase();
                final filtered = tours.where((t) {
                  if (query.isNotEmpty &&
                      !t.title.toLowerCase().contains(query) &&
                      !t.destination.toLowerCase().contains(query)) {
                    return false;
                  }
                  if (_selectedFilter == 'Nigeria' && t.isInternational) {
                    return false;
                  }
                  if (_selectedFilter == 'International' && !t.isInternational) {
                    return false;
                  }
                  if (_selectedFilter != 'All' &&
                      _selectedFilter != 'Nigeria' &&
                      _selectedFilter != 'International') {
                    final filterLower = _selectedFilter.toLowerCase();
                    if (!t.categories
                        .any((c) => c.toLowerCase().contains(filterLower))) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'No tours match your search',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    0,
                    AppSizes.lg,
                    AppSizes.lg,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.md),
                  itemBuilder: (context, index) {
                    final tour = filtered[index];
                    return TourCard(
                      tour: tour,
                      onTap: () => context.push('/tour/${tour.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
