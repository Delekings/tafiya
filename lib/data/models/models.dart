/// Tour package model — main entity in the marketplace
class Tour {
  final String id;
  final String title;
  final String destination;
  final String country;
  final String coverImage;
  final List<String> images;
  final double pricePerPerson;
  final String currency; // 'NGN' or 'USD'
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final int totalSlots;
  final int slotsTaken;
  final List<String> categories; // e.g. ['solo-friendly', 'beach', 'cultural']
  final bool isInternational;
  final String operatorId;
  final String operatorName;
  final String operatorAvatar;
  final bool operatorVerified;
  final double rating;
  final int reviewCount;
  final List<String> highlights;
  final List<ItineraryDay> itinerary;
  final List<String> included;
  final List<String> excluded;
  final String description;

  Tour({
    required this.id,
    required this.title,
    required this.destination,
    required this.country,
    required this.coverImage,
    required this.images,
    required this.pricePerPerson,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.totalSlots,
    required this.slotsTaken,
    required this.categories,
    required this.isInternational,
    required this.operatorId,
    required this.operatorName,
    required this.operatorAvatar,
    required this.operatorVerified,
    required this.rating,
    required this.reviewCount,
    required this.highlights,
    required this.itinerary,
    required this.included,
    required this.excluded,
    required this.description,
  });

  int get slotsRemaining => totalSlots - slotsTaken;
  bool get isFull => slotsRemaining <= 0;

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      country: json['country'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      pricePerPerson: (json['price_per_person'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      durationDays: json['duration_days'] as int,
      totalSlots: json['total_slots'] as int,
      slotsTaken: json['slots_taken'] as int? ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      isInternational: json['is_international'] as bool? ?? false,
      operatorId: json['operator_id'] as String,
      operatorName: json['operator_name'] as String? ?? '',
      operatorAvatar: json['operator_avatar'] as String? ?? '',
      operatorVerified: json['operator_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      highlights: List<String>.from(json['highlights'] ?? []),
      itinerary: (json['itinerary'] as List? ?? [])
          .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      included: List<String>.from(json['included'] ?? []),
      excluded: List<String>.from(json['excluded'] ?? []),
      description: json['description'] as String? ?? '',
    );
  }
}

class ItineraryDay {
  final int day;
  final String title;
  final String description;
  final List<String> activities;

  ItineraryDay({
    required this.day,
    required this.title,
    required this.description,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: json['day'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      activities: List<String>.from(json['activities'] ?? []),
    );
  }
}

/// User profile — extends Supabase auth user with app-specific fields
class TafiyaUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String explorerTier; // 'wanderer', 'voyager', 'explorer', 'legend'
  final int xpPoints;
  final int loyaltyPoints;
  final DateTime createdAt;
  final bool isOperator;
  final bool isGuide;
  final bool isGuideVerified;

  TafiyaUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.explorerTier = 'wanderer',
    this.xpPoints = 0,
    this.loyaltyPoints = 0,
    required this.createdAt,
    this.isOperator = false,
    this.isGuide = false,
    this.isGuideVerified = false,
  });

  factory TafiyaUser.fromJson(Map<String, dynamic> json) {
    return TafiyaUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      explorerTier: json['explorer_tier'] as String? ?? 'wanderer',
      xpPoints: json['xp_points'] as int? ?? 0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOperator: json['is_operator'] as bool? ?? false,
      isGuide: json['is_guide'] as bool? ?? false,
      isGuideVerified: json['is_guide_verified'] as bool? ?? false,
    );
  }
}

/// Savings plan with auto-debit and 5% withdrawal penalty
class SavingsPlan {
  final String id;
  final String userId;
  final String name; // e.g. "Dubai December"
  final String? tourId; // optional — if saving toward a specific tour
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final DateTime startDate;
  final DateTime targetDate;
  final String status; // 'active', 'paused', 'completed', 'withdrawn'
  final String paymentMethodId;
  final int debitDayOfMonth;
  final bool autoDebitEnabled;

  SavingsPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.tourId,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.paymentMethodId,
    required this.debitDayOfMonth,
    required this.autoDebitEnabled,
  });

  double get progressPercent =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  /// 5% penalty on early withdrawal (before goal reached)
  double calculateWithdrawalPenalty() {
    if (status == 'completed') return 0;
    return currentAmount * 0.05;
  }

  double get amountAfterPenalty =>
      currentAmount - calculateWithdrawalPenalty();

  factory SavingsPlan.fromJson(Map<String, dynamic> json) {
    return SavingsPlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      tourId: json['tour_id'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      monthlyContribution: (json['monthly_contribution'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      targetDate: DateTime.parse(json['target_date'] as String),
      status: json['status'] as String,
      paymentMethodId: json['payment_method_id'] as String,
      debitDayOfMonth: json['debit_day_of_month'] as int? ?? 1,
      autoDebitEnabled: json['auto_debit_enabled'] as bool? ?? true,
    );
  }
}

/// Booking record
class Booking {
  final String id;
  final String userId;
  final String tourId;
  final Tour? tour;
  final DateTime bookedAt;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double totalAmount;
  final double amountPaid;
  final String paymentPlan; // 'full', 'installment'
  final int installmentMonths;

  Booking({
    required this.id,
    required this.userId,
    required this.tourId,
    this.tour,
    required this.bookedAt,
    required this.status,
    required this.totalAmount,
    required this.amountPaid,
    required this.paymentPlan,
    required this.installmentMonths,
  });

  double get balanceRemaining => totalAmount - amountPaid;
  bool get isFullyPaid => amountPaid >= totalAmount;
}
