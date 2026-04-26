import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub auth layer for running without Supabase (Dart 3.3 web compile blocker).
/// Mimics the same provider names used by the rest of the app so we can swap
/// real Supabase back in later by replacing this file.

class MockUser {
  final String id;
  final String email;
  final Map<String, dynamic> userMetadata;

  MockUser({
    required this.id,
    required this.email,
    required this.userMetadata,
  });
}

class MockAuth {
  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = MockUser(
      id: 'demo-user',
      email: email,
      userMetadata: {'full_name': email.split('@').first},
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = MockUser(
      id: 'demo-user',
      email: email,
      userMetadata: data ?? {'full_name': email.split('@').first},
    );
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}

class MockSupabaseClient {
  final MockAuth auth = MockAuth();
}

final supabaseClientProvider = Provider<MockSupabaseClient>((ref) {
  return MockSupabaseClient();
});

/// Currently signed-in user (null if signed out).
final currentUserProvider = StateProvider<MockUser?>((ref) {
  return MockUser(
    id: 'demo-user',
    email: 'demo@tafiya.app',
    userMetadata: {'full_name': 'Demo Traveler'},
  );
});
