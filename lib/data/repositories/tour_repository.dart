import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class TourRepository {
  // TODO: Replace with Supabase queries when backend is connected
  // Example:
  // final SupabaseClient client;
  // TourRepository(this.client);
  // Future<List<Tour>> getTours() async {
  //   final res = await client.from('tours').select().order('start_date');
  //   return (res as List).map((e) => Tour.fromJson(e)).toList();
  // }

  Future<List<Tour>> getTours() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.tours;
  }

  Future<Tour?> getTourById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockData.tours.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Tour>> getFeaturedTours() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.tours.take(3).toList();
  }

  Future<List<Tour>> getTrendingTours() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.tours.where((t) => t.rating >= 4.7).toList();
  }
}

final tourRepositoryProvider = Provider<TourRepository>((ref) {
  return TourRepository();
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
