import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../state/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  bool _saving = false;
  File? _pickedImage;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _nameCtrl.text = user?.userMetadata?['full_name'] as String? ?? '';
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() => _avatarUrl = data['avatar_url'] as String?);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
      if (picked != null && mounted) setState(() => _pickedImage = File(picked.path));
    } catch (_) {}
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_pickedImage == null) return _avatarUrl;

    final file = _pickedImage!;
    // Use a timestamp-based filename to avoid caching and collision issues
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/avatar_$ts.jpg';

    try {
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, bytes);
      return Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return _avatarUrl; // fallback to existing
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Upload avatar (falls back to existing URL if upload fails or no new image)
      final avatarUrl = await _uploadAvatar(userId);

      // Update profile in Supabase
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'full_name': _nameCtrl.text.trim(),
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update user metadata
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'full_name': _nameCtrl.text.trim()}),
        );
      } catch (_) {}

      // Update shared avatar provider (instant refresh in profile + nav bar)
      ref.read(avatarProvider.notifier).setAvatar(avatarUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(children: [
                ClipOval(
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, width: 112, height: 112, fit: BoxFit.cover)
                      : _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _avatarUrl!,
                              width: 112, height: 112, fit: BoxFit.cover,
                              placeholder: (_, __) => _initialsCircle(_nameCtrl.text),
                              errorWidget: (_, __, ___) => _initialsCircle(_nameCtrl.text),
                            )
                          : _initialsCircle(_nameCtrl.text),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 32),

          // Name
          _sectionTitle(l10n.changeName, isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: l10n.fullName,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 24),

          // Email (read-only)
          _sectionTitle('Email', isDark),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard.withAlpha(120) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              user?.email ?? '',
              style: TextStyle(color: isDark ? AppColors.cream.withAlpha(140) : AppColors.warmGray),
            ),
          ),

          const SizedBox(height: 28),

          // Change password
          _sectionTitle(l10n.changePassword, isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _currentPwCtrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.currentPassword,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPwCtrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.newPassword,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 32),

          // Save
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded),
              label: Text(_saving ? 'Saving...' : l10n.saveChanges),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.cream : AppColors.charcoal));
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  Widget _initialsCircle(String name) {
    return CircleAvatar(
      radius: 56,
      backgroundColor: AppColors.gold.withAlpha(40),
      child: Text(
        _initials(name),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.gold),
      ),
    );
  }
}
