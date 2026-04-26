import 'package:flutter/material.dart';

/// Brand colors for Tafiya — inspired by Nigerian landscapes:
/// deep forest green (Obudu), sunset terracotta (Northern dunes),
/// and warm cream backgrounds.
class AppColors {
  AppColors._();

  // Primary - Deep forest green (signifies journey, growth, nature)
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF2D6A4F);
  static const Color primaryDark = Color(0xFF081C15);

  // Accent - Terracotta sunset
  static const Color accent = Color(0xFFE07856);
  static const Color accentLight = Color(0xFFF4A261);
  static const Color accentDark = Color(0xFFC65D3D);

  // Neutrals
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1ECE4);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C5C);
  static const Color textTertiary = Color(0xFF8A8A8A);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF2D6A4F);
  static const Color error = Color(0xFFC53030);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E0D8);
  static const Color divider = Color(0xFFEDE8DF);
}

class AppStrings {
  AppStrings._();

  static const String appName = 'Tafiya';
  static const String tagline = 'Every journey, simplified';

  // Onboarding
  static const String onboarding1Title = 'Discover Nigeria\n& Beyond';
  static const String onboarding1Body =
      'Curated group and solo tours from verified operators across Africa and the world.';

  static const String onboarding2Title = 'Save Your Way\nto Travel';
  static const String onboarding2Body =
      'Set a savings goal, pay in installments, and let us hold you accountable to your dream trip.';

  static const String onboarding3Title = 'Travel Together,\nStay Connected';
  static const String onboarding3Body =
      'In-app group chats, live trip tracking, and verified co-travelers — every step of the way.';
}

class AppSizes {
  AppSizes._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}

class SupabaseConfig {
  SupabaseConfig._();

  // TODO: Replace with your actual Supabase project credentials
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
