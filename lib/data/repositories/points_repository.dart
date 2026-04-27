import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../services/supabase_service.dart';

class PointBalance {
  final int balance;
  final int lifetimeEarned;
  final int lifetimeSpent;

  PointBalance({
    required this.balance,
    required this.lifetimeEarned,
    required this.lifetimeSpent,
  });

  factory PointBalance.fromJson(Map<String, dynamic> json) {
    return PointBalance(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      lifetimeEarned: (json['lifetime_earned'] as num?)?.toInt() ?? 0,
      lifetimeSpent: (json['lifetime_spent'] as num?)?.toInt() ?? 0,
    );
  }

  /// Whether this user qualifies for buyback (50k threshold).
  bool get canBuyback => balance >= 50000;

  /// What the user would receive in naira if they sold all eligible points.
  double get buybackPayout => balance * 0.9;
}

class PointTransaction {
  final String id;
  final int amount; // positive = credit, negative = debit
  final String type;
  final String? description;
  final String? relatedUserId;
  final DateTime createdAt;

  PointTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    this.relatedUserId,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String,
      description: json['description'] as String?,
      relatedUserId: json['related_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
}

class PointsRepository {
  final SupabaseClient client;
  PointsRepository(this.client);

  Future<PointBalance> getBalance() async {
    final user = client.auth.currentUser;
    if (user == null) {
      return PointBalance(balance: 0, lifetimeEarned: 0, lifetimeSpent: 0);
    }
    final res = await client
        .from('point_balances')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    if (res == null) {
      return PointBalance(balance: 0, lifetimeEarned: 0, lifetimeSpent: 0);
    }
    return PointBalance.fromJson(res as Map<String, dynamic>);
  }

  Future<List<PointTransaction>> getTransactions({int limit = 50}) async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    final res = await client
        .from('point_transactions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List)
        .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get the user's referral code
  Future<String?> getReferralCode() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res = await client
        .from('profiles')
        .select('referral_code')
        .eq('id', user.id)
        .maybeSingle();
    if (res == null) return null;
    return res['referral_code'] as String?;
  }
}

final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PointsRepository(client);
});

final pointBalanceProvider = FutureProvider<PointBalance>((ref) async {
  final repo = ref.watch(pointsRepositoryProvider);
  return repo.getBalance();
});

final pointTransactionsProvider =
FutureProvider<List<PointTransaction>>((ref) async {
  final repo = ref.watch(pointsRepositoryProvider);
  return repo.getTransactions();
});

final referralCodeProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(pointsRepositoryProvider);
  return repo.getReferralCode();
});