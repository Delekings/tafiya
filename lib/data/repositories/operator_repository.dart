import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/models.dart';
import '../services/supabase_service.dart';

class Operator {
  final String id;
  final String userId;
  final String businessName;
  final String? description;
  final String? logoUrl;
  final String? coverImage;
  final bool verified;
  final double rating;
  final int reviewCount;
  final String? cacNumber;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime createdAt;

  Operator({
    required this.id,
    required this.userId,
    required this.businessName,
    this.description,
    this.logoUrl,
    this.coverImage,
    required this.verified,
    required this.rating,
    required this.reviewCount,
    this.cacNumber,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImage: json['cover_image'] as String?,
      verified: json['verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      cacNumber: json['cac_number'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class OperatorRepository {
  final SupabaseClient client;
  OperatorRepository(this.client);

  Future<Operator?> getMyOperator() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final res = await client
        .from('operators')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (res == null) return null;
    return Operator.fromJson(res as Map<String, dynamic>);
  }

  Future<Operator> createOperator({
    required String businessName,
    String? description,
    String? contactEmail,
    String? contactPhone,
    String? cacNumber,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final res = await client
        .from('operators')
        .insert({
      'user_id': user.id,
      'business_name': businessName,
      'description': description,
      'contact_email': contactEmail ?? user.email,
      'contact_phone': contactPhone,
      'cac_number': cacNumber,
    })
        .select()
        .single();

    await client
        .from('profiles')
        .update({'is_operator': true})
        .eq('id', user.id);

    return Operator.fromJson(res as Map<String, dynamic>);
  }

  Future<List<Tour>> getMyTours() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final operator = await getMyOperator();
    if (operator == null) return [];

    final res = await client
        .from('tours')
        .select('*, operators(business_name, logo_url, verified)')
        .eq('operator_id', operator.id)
        .order('created_at', ascending: false);

    return (res as List).map((e) {
      final row = e as Map<String, dynamic>;
      final op = row['operators'] as Map<String, dynamic>?;
      return Tour.fromJson({
        ...row,
        'operator_name': op?['business_name'] ?? '',
        'operator_avatar': op?['logo_url'] ?? '',
        'operator_verified': op?['verified'] ?? false,
      });
    }).toList();
  }

  Future<Tour> createTour({
    required String title,
    required String destination,
    required String country,
    required String coverImage,
    required double pricePerPerson,
    required String currency,
    required DateTime startDate,
    required DateTime endDate,
    required int totalSlots,
    required List<String> categories,
    required bool isInternational,
    required List<String> highlights,
    required List<String> included,
    required List<String> excluded,
    required String description,
    bool isPublished = false,
  }) async {
    final operator = await getMyOperator();
    if (operator == null) throw Exception('No operator account');

    final durationDays = endDate.difference(startDate).inDays + 1;

    final res = await client
        .from('tours')
        .insert({
      'operator_id': operator.id,
      'title': title,
      'destination': destination,
      'country': country,
      'cover_image': coverImage,
      'price_per_person': pricePerPerson,
      'currency': currency,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'duration_days': durationDays,
      'total_slots': totalSlots,
      'categories': categories,
      'is_international': isInternational,
      'highlights': highlights,
      'included': included,
      'excluded': excluded,
      'description': description,
      'is_published': isPublished,
    })
        .select('*, operators(business_name, logo_url, verified)')
        .single();

    final row = res as Map<String, dynamic>;
    final op = row['operators'] as Map<String, dynamic>?;
    return Tour.fromJson({
      ...row,
      'operator_name': op?['business_name'] ?? '',
      'operator_avatar': op?['logo_url'] ?? '',
      'operator_verified': op?['verified'] ?? false,
    });
  }

  Future<void> setTourPublished(String tourId, bool published) async {
    await client
        .from('tours')
        .update({'is_published': published})
        .eq('id', tourId);
  }
}

final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return OperatorRepository(client);
});

final myOperatorProvider = FutureProvider<Operator?>((ref) async {
  final repo = ref.watch(operatorRepositoryProvider);
  return repo.getMyOperator();
});

final myToursProvider = FutureProvider<List<Tour>>((ref) async {
  final repo = ref.watch(operatorRepositoryProvider);
  return repo.getMyTours();
});