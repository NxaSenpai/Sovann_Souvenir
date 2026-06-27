import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cached avatar URL — loads from SharedPreferences instantly,
/// then fetches from Supabase in the background.
class AvatarNotifier extends Notifier<String?> {
  static const _cacheKey = 'profile_avatar_url';

  @override
  String? build() {
    _loadCached();
    _fetchFromSupabase();
    return null;
  }

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached;
    }
  }

  Future<void> _fetchFromSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (data != null) {
        final url = data['avatar_url'] as String?;
        if (url != null && url.isNotEmpty) {
          state = url;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, url);
        }
      }
    } catch (_) {}
  }

  /// Called after saving profile — updates state and cache immediately.
  void setAvatar(String? url) {
    state = url;
    if (url != null && url.isNotEmpty) {
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setString(_cacheKey, url),
      );
    }
  }
}

final avatarProvider = NotifierProvider<AvatarNotifier, String?>(
  AvatarNotifier.new,
);
