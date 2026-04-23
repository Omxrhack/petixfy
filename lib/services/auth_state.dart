import 'dart:convert';

import 'package:petixfy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAuthState {
  AppAuthState._();

  static const _storageKey = 'vetgo_auth_state';
  static String? accessToken;
  static String? refreshToken;
  static String? email;
  static bool isVerified = false;
  static bool onboardingCompleted = false;

  static Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      accessToken = map['access_token'] as String?;
      refreshToken = map['refresh_token'] as String?;
      email = map['email'] as String?;
      isVerified = map['is_verified'] as bool? ?? false;
      onboardingCompleted = map['onboarding_completed'] as bool? ?? false;
      await _syncSupabaseSession();
    } catch (_) {
      await clear();
    }
  }

  static Future<void> save({
    String? newAccessToken,
    String? newRefreshToken,
    String? newEmail,
    bool? newIsVerified,
    bool? newOnboardingCompleted,
  }) async {
    accessToken = newAccessToken ?? accessToken;
    refreshToken = newRefreshToken ?? refreshToken;
    email = newEmail ?? email;
    isVerified = newIsVerified ?? isVerified;
    onboardingCompleted = newOnboardingCompleted ?? onboardingCompleted;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'email': email,
        'is_verified': isVerified,
        'onboarding_completed': onboardingCompleted,
      }),
    );

    await _syncSupabaseSession();
  }

  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    email = null;
    isVerified = false;
    onboardingCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await supabase.auth.signOut();
  }

  static Future<void> _syncSupabaseSession() async {
    if (accessToken == null || refreshToken == null) {
      return;
    }
    try {
      await supabase.auth.setSession(refreshToken!);
    } catch (_) {
      // Ignore session sync issues and keep local auth flow.
    }
  }
}
