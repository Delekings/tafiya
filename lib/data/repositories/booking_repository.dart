import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/models.dart';
import '../services/supabase_service.dart';

class BookingRepository {
  final SupabaseClient client;
  BookingRepository(this.client);

  /// Creates a real booking via the SQL function.
  /// Returns the new booking's UUID.
  Future<String> createBooking({
    required String tourId,
    required int travelers,
    required double totalAmount,
    required String paymentPlan,
    required int installmentMonths,
    required double amountPaid,
    int pointsUsed = 0,
  }) async {
    final result = await client.rpc('create_booking', params: {
      'p_tour_id': tourId,
      'p_travelers': travelers,
      'p_total_amount': totalAmount,
      'p_payment_plan': paymentPlan,
      'p_installment_months': installmentMonths,
      'p_amount_paid': amountPaid,
      'p_points_used': pointsUsed,
    });
    return result as String;
  }

  /// Get all bookings for the current user, with the tour and operator joined.
  Future<List<Booking>> getMyBookings() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final res = await client
        .from('bookings')
        .select('*, tours!inner(*, operators(business_name, logo_url, verified))')
        .eq('user_id', user.id)
        .order('booked_at', ascending: false);

    return (res as List).map((e) {
      final row = e as Map<String, dynamic>;
      final tourRow = row['tours'] as Map<String, dynamic>?;
      Tour? tour;
      if (tourRow != null) {
        final operator = tourRow['operators'] as Map<String, dynamic>?;
        tour = Tour.fromJson({
          ...tourRow,
          'operator_name': operator?['business_name'] ?? '',
          'operator_avatar': operator?['logo_url'] ?? '',
          'operator_verified': operator?['verified'] ?? false,
        });
      }
      return Booking(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        tourId: row['tour_id'] as String,
        tour: tour,
        bookedAt: DateTime.parse(row['booked_at'] as String),
        status: row['status'] as String,
        totalAmount: (row['total_amount'] as num).toDouble(),
        amountPaid: (row['amount_paid'] as num?)?.toDouble() ?? 0,
        paymentPlan: row['payment_plan'] as String? ?? 'full',
        installmentMonths: (row['installment_months'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BookingRepository(client);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyBookings();
});