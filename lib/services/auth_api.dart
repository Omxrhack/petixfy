import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:petixfy/services/auth_state.dart';

class AuthApi {
  AuthApi._();

  // iOS simulator can access localhost directly. Physical devices require LAN IP.
  static const String _baseUrl = String.fromEnvironment(
    'VETGO_BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      _uri('/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String token,
  }) async {
    final res = await http.post(
      _uri('/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
      }),
    );
    final data = _decode(res);
    await _saveSessionFromResponse(data, fallbackEmail: email);
    return data;
  }

  static Future<Map<String, dynamic>> onboarding(Map<String, dynamic> payload) async {
    final token = AppAuthState.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No active session for onboarding');
    }

    final res = await http.post(
      _uri('/api/auth/onboarding'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final data = _decode(res);
    final profile = (data['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    await AppAuthState.save(
      newIsVerified: profile['is_verified'] as bool? ?? AppAuthState.isVerified,
      newOnboardingCompleted:
          profile['onboarding_completed'] as bool? ?? AppAuthState.onboardingCompleted,
      newEmail: AppAuthState.email,
    );
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      _uri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decode(res);
    await _saveSessionFromResponse(data, fallbackEmail: email);
    return data;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final map = response.body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(response.body) as Map<String, dynamic>);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    final message = map['error']?.toString() ?? 'Request failed';
    throw Exception(message);
  }

  static Future<void> _saveSessionFromResponse(
    Map<String, dynamic> data, {
    required String fallbackEmail,
  }) async {
    final user = (data['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    await AppAuthState.save(
      newAccessToken: data['access_token'] as String?,
      newRefreshToken: data['refresh_token'] as String?,
      newEmail: user['email'] as String? ?? fallbackEmail,
      newIsVerified: user['is_verified'] as bool? ?? false,
      newOnboardingCompleted: user['onboarding_completed'] as bool? ?? false,
    );
  }
}
