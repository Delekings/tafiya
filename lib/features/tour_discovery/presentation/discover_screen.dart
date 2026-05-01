import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/tour_repository.dart';
import '../../../shared/widgets/tour_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const DiscoverScreen({super.key, this.initialCategory});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  late String _selectedFilter;

  static const _filters = [
    'All',
    'Nigeria',
    'International',
    'Beach',
    'Cultural',
    'Adventure',
    'Festivals',
    'Honeymoon',
    'Group',
    'Solo',
  ];

  @override
  void initState() {
    super.initState();
    // Map the incoming category (lowercase from URL) to a filter chip label.
    final c = widget.initialCategory?.toLowerCase();
    _selectedFilter = _filters.firstWhere(
          (f) => f.toLowerCase() == c,
      orElse: () => 'All',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Custom intro shown above results for special categories.
  Widget? _categoryIntro() {
    switch (_selectedFilter) {
      case 'Honeymoon':
        return _IntroBanner(
          emoji: '💕',
          title: 'Curated romantic escapes',
          body: 'Hand-picked experiences for couples. Private dinners, secluded suites, and once-in-a-lifetime moments.',
          tint: const Color(0xFFFCE7F0),
        );
      case 'Festivals':
        return _IntroBanner(
          emoji: '🎉',
          title: 'Festival season',
          body: 'Detty December, Calabar Carnival, Felabration & more — plan around the moments that matter.',
          tint: const Color(0xFFFCE7E7),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(allToursProvider);
    final intro = _categoryIntro();

    return SafeArea(
      child: Column(
        children: [
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
                Row(
                  children: [
                    if (widget.initialCategory != null && context.canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        widget.initialCategory != null
                            ? _selectedFilter
                            : 'Discover',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ],
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
          if (intro != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
              child: intro,
            ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.explore_off_rounded,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'No ${_selectedFilter.toLowerCase()} tours yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New ones drop weekly. Check back soon or try another category.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

class _IntroBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Color tint;

  const _IntroBanner({
    required this.emoji,
    required this.title,
    required this.body,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}