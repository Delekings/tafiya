import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../../../core/constants/app_constants.dart';
import '../../../data/services/supabase_service.dart';

// =============================================
// Profile data provider
// =============================================
final myProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>(
      (ref) async {
    final client = ref.watch(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return res as Map<String, dynamic>?;
  },
);

// =============================================
// Edit profile screen
// =============================================
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  int? _birthDay;
  int? _birthMonth;
  int? _birthYear;

  String? _avatarUrl;
  Uint8List? _pickedAvatarBytes;
  String? _pickedAvatarExt;

  bool _saving = false;
  bool _initialized = false;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(100, (i) => now - 18 - i); // 18+ users only
  }

  List<int> get _days {
    if (_birthMonth == null || _birthYear == null) {
      return List.generate(31, (i) => i + 1);
    }
    final daysInMonth = DateTime(_birthYear!, _birthMonth! + 1, 0).day;
    return List.generate(daysInMonth, (i) => i + 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(Map<String, dynamic> profile) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = (profile['full_name'] as String?) ?? '';
    _phoneController.text = (profile['phone'] as String?) ?? '';
    _bioController.text = (profile['bio'] as String?) ?? '';
    _avatarUrl = profile['avatar_url'] as String?;
    final dob = profile['date_of_birth'] as String?;
    if (dob != null) {
      try {
        final d = DateTime.parse(dob);
        _birthDay = d.day;
        _birthMonth = d.month;
        _birthYear = d.year;
      } catch (_) {}
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedAvatarBytes = bytes;
      _pickedAvatarExt = picked.name.split('.').last.toLowerCase();
    });
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_pickedAvatarBytes == null) return _avatarUrl;
    final client = ref.read(supabaseClientProvider);
    final ext = _pickedAvatarExt ?? 'jpg';
    final path = '$userId/avatar.$ext';
    await client.storage.from('avatars').uploadBinary(
      path,
      _pickedAvatarBytes!,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/$ext',
      ),
    );
    final url = client.storage.from('avatars').getPublicUrl(path);
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      final newAvatarUrl = await _uploadAvatar(user.id);

      String? dobIso;
      if (_birthDay != null && _birthMonth != null && _birthYear != null) {
        dobIso = DateTime(_birthYear!, _birthMonth!, _birthDay!)
            .toIso8601String()
            .split('T')
            .first;
      }

      await client.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'date_of_birth': dobIso,
        'avatar_url': newAvatarUrl,
      }).eq('id', user.id);

      ref.invalidate(myProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          _hydrateFromProfile(profile);
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    final initial = _nameController.text.isEmpty
        ? '?'
        : _nameController.text[0].toUpperCase();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.lg),
            children: [
              // Avatar picker
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: _pickedAvatarBytes != null
                                ? DecorationImage(
                              image:
                              MemoryImage(_pickedAvatarBytes!),
                              fit: BoxFit.cover,
                            )
                                : (_avatarUrl != null
                                ? DecorationImage(
                              image: NetworkImage(_avatarUrl!),
                              fit: BoxFit.cover,
                            )
                                : null),
                          ),
                          child: (_pickedAvatarBytes == null &&
                              _avatarUrl == null)
                              ? Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Change photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Name
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSizes.md),

              // Phone
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: '+234...',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Date of birth
              Text(
                'Date of birth',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'For your 2,000-pt birthday gift each year 🎂',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      value: _birthMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(12, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(_months[i]),
                        );
                      }),
                      onChanged: (v) {
                        setState(() {
                          _birthMonth = v;
                          if (_birthDay != null && _birthDay! > _days.length) {
                            _birthDay = _days.length;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _birthDay,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: _days.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text('$d'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _birthDay = v),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _birthYear,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: _years.map((y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text('$y'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _birthYear = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              // Bio
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Bio (optional)',
                  hintText: 'Where are you from? What kind of trips do you love?',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),

        // Save button
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.md + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
                top: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: _saving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text('Save changes'),
          ),
        ),
      ],
    );
  }
}