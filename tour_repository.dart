import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../services/supabase_service.dart';

class TourRepository {
  final SupabaseClient client;
  TourRepository(this.client);

  /// Build a Tour from a Supabase row, joining the related operator.
  Tour _toTour(Map<String, dynamic> row) {
    final operator = row['operators'] as Map<String, dynamic>?;
    return Tour.fromJson({
      ...row,
      'operator_name': operator?['business_name'] ?? '',
      'operator_avatar': operator?['logo_url'] ?? '',
      'operator_verified': operator?['verified'] ?? false,
    });
  }

  Future<List<Tour>> getTours() async {
    try {
      final res = await client
          .from('tours')
          .select('*, operators(business_name, logo_url, verified)')
          .eq('is_published', true)
          .order('start_date');
      return (res as List)
          .map((e) => _toTour(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase unreachable (dev convenience)
      // ignore: avoid_print
      print('Supabase tours fetch failed, using mock: $e');
      return MockData.tours;
    }
  }

  Future<Tour?> getTourById(String id) async {
    try {
      final res = await client
          .from('tours')
          .select('*, operators(business_name, logo_url, verified)')
          .eq('id', id)
          .maybeSingle();
      if (res == null) return null;
      return _toTour(res as Map<String, dynamic>);
    } catch (e) {
      try {
        return MockData.tours.firstWhere((t) => t.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<Tour>> getFeaturedTours() async {
    final all = await getTours();
    return all.take(3).toList();
  }

  Future<List<Tour>> getTrendingTours() async {
    final all = await getTours();
    return all.where((t) => t.rating >= 4.7).toList();
  }
}

final tourRepositoryProvider = Provider<TourRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TourRepository(client);
});

final allToursProvider = FutureProvider<List<Tour>>((ref) async {
  final repo = ref.watch(tourRepositoryProvider);
  return repo.getTours();
});

final featuredToursProvider = FutureProvider<List<Tour>>((ref) async {
  final repo = ref.watch(tourRepositoryProvider);
  return repo.getFeaturedTours();
});

final trendingToursProvider = FutureProvider<List<Tour>>((ref) async {
  final repo = ref.watch(tourRepositoryProvider);
  return repo.getTrendingTours();
});

final tourByIdProvider =
    FutureProvider.family<Tour?, String>((ref, id) async {
  final repo = ref.watch(tourRepositoryProvider);
  return repo.getTourById(id);
});
