# Tafiya — Nigeria's Tour Marketplace

> _Tafiya_ (Hausa: "journey, trip") — Every journey, simplified.

A Flutter mobile app skeleton for Nigeria's first group & solo tour marketplace. Built with Riverpod, Supabase, and go_router.

---

## ✨ What's in this build

This is a **complete, navigable app skeleton** with mock data — every screen wires together, the bottom nav works, all flows (auth → home → tour details → booking → savings → group chat → profile) are connected.

### Implemented screens

- **Splash** — animated logo entry
- **Onboarding** — 3-slide PageView with smooth indicator
- **Login / Register** — Supabase email/password auth wired
- **Home** — Hausa greeting, search, categories carousel, savings banner, featured tours, trending, become-a-guide CTA
- **Discover** — searchable, filterable tour list
- **Tour Details** — hero image, operator info, highlights, included items
- **Booking** — full payment vs installment, traveler count, escrow notice
- **Savings Wallet** — total saved card, plans with progress bars, **5% withdrawal penalty** logic shown in withdraw bottom sheet
- **Create Savings Plan** — auto-debit form with target/monthly/debit-day
- **Group Chat** — per-booking chat with operator highlighting
- **Profile** — avatar, stats, account/Tafiya/support menus, sign-out
- **Become a Guide** — full enrollment landing with tier cards & verification steps

### Architecture

```
lib/
├── core/              # constants, theme, router, errors
├── data/              # models, repositories, services (Supabase)
├── domain/            # business entities & use cases
├── features/          # one folder per feature, presentation layer
├── shared/            # reusable widgets (TourCard, etc.)
└── main.dart          # Supabase init + ProviderScope
```

**State management:** Riverpod 2.x (providers in each feature, global ones in `data/`)
**Routing:** go_router with `ShellRoute` for bottom nav + sub-routes for full-screen flows
**Backend:** Supabase (auth wired; mock data for tours until you point repository at your tables)

### Design system

- **Primary** `#1B4332` deep forest green
- **Accent** `#E07856` terracotta sunset
- **Background** `#FAF7F2` warm cream
- **Type pair:** Fraunces (serif display) + DM Sans (body) — loaded via `google_fonts`

---

## 🚀 Running it

### 1. Prerequisites

- Flutter 3.27+ / Dart 3.5+
- Android Studio or Xcode for emulators
- A Supabase project ([create one free](https://supabase.com))

### 2. Install dependencies

```bash
cd tafiya_app
flutter pub get
```

### 3. Configure Supabase

Open `lib/core/constants/app_constants.dart` and replace:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

with your project's URL and anon key (Supabase Dashboard → Settings → API).

### 4. Run

```bash
flutter run
```

---

## 🗄️ Suggested Supabase schema (when you're ready)

```sql
-- profiles (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  phone text,
  avatar_url text,
  explorer_tier text default 'wanderer',
  xp_points int default 0,
  is_operator bool default false,
  is_guide bool default false,
  is_guide_verified bool default false,
  created_at timestamptz default now()
);

-- tours
create table public.tours (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid references public.profiles(id),
  title text not null,
  destination text,
  country text,
  cover_image text,
  price_per_person numeric,
  currency text default 'NGN',
  start_date date,
  end_date date,
  duration_days int,
  total_slots int,
  slots_taken int default 0,
  categories text[],
  is_international bool default false,
  rating numeric default 0,
  review_count int default 0,
  highlights text[],
  included text[],
  excluded text[],
  description text,
  created_at timestamptz default now()
);

-- savings_plans
create table public.savings_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  tour_id uuid references public.tours(id),
  name text,
  target_amount numeric,
  current_amount numeric default 0,
  monthly_contribution numeric,
  start_date date,
  target_date date,
  status text default 'active',
  payment_method_id text,
  debit_day_of_month int default 1,
  auto_debit_enabled bool default true,
  created_at timestamptz default now()
);

-- bookings
create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  tour_id uuid references public.tours(id),
  status text default 'pending',
  total_amount numeric,
  amount_paid numeric default 0,
  payment_plan text default 'full',
  installment_months int,
  travelers int default 1,
  booked_at timestamptz default now()
);

-- Enable Row Level Security and add policies for each table.
```

To swap mock data for real queries, edit `lib/data/repositories/tour_repository.dart`:

```dart
Future<List<Tour>> getTours() async {
  final res = await client.from('tours').select().order('start_date');
  return (res as List).map((e) => Tour.fromJson(e)).toList();
}
```

---

## 🚧 What's NOT yet built (pending work)

- Operator dashboard (list/edit your tours)
- Trips screen (user's bookings list)
- Live trip tracking with Google Maps
- Paystack/Flutterwave payment integration (deps installed, no flow yet)
- Push notifications (Firebase deps installed, no setup yet)
- Hausa/Yoruba/Igbo localizations
- Offline mode with Hive caching

---

## 💡 The 5% withdrawal penalty

The signature savings feature is implemented in `SavingsPlan.calculateWithdrawalPenalty()`:

```dart
double calculateWithdrawalPenalty() {
  if (status == 'completed') return 0;
  return currentAmount * 0.05;
}
```

The withdraw bottom sheet on the savings screen breaks down `Available → Penalty → You'll receive`. When funds are applied to a booking instead, no penalty is charged.

---

Built with care for Nigerian travelers. Sannu da zuwa. 🇳🇬
