import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

class AvatarNotifier extends Notifier<String?> {
  static const _cacheKey = 'profile_avatar_url';

  @override
  String? build() {
    final auth = ref.watch(authProvider);
    if (auth == AppAuthState.authenticated) {
      _sync();
    } else {
      state = null;
    }
    return null;
  }

  Future<void> _sync() async {
    // 1. Show cached instantly
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached;
    }

    // 2. Fetch real data from Supabase (always wins)
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
          await prefs.setString(_cacheKey, url);
        }
      }
    } catch (_) {}
  }

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
