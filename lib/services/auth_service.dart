import 'package:dio/dio.dart';
import 'package:petixfy/models/user.dart';
import 'package:petixfy/network/api_client.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final User user;
  final String accessToken;
  final String? refreshToken;
}

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthLoginResult> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = (response.data as Map).cast<String, dynamic>();
      final accessToken = body['access_token']?.toString();
      final refreshToken = body['refresh_token']?.toString();
      final userJson = (body['user'] as Map?)?.cast<String, dynamic>();

      if (accessToken == null || accessToken.isEmpty || userJson == null) {
        throw const AuthServiceException('Invalid login response from server');
      }

      return AuthLoginResult(
        user: User.fromJson(userJson),
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on AuthServiceException {
      rethrow;
    } on DioException catch (e) {
      throw AuthServiceException(_extractDioMessage(e));
    } catch (_) {
      throw const AuthServiceException('Unexpected error while logging in');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/verify-otp',
        data: {
          'email': email,
          'token': code,
        },
      );
      return (response.data as Map).cast<String, dynamic>();
    } on AuthServiceException {
      rethrow;
    } on DioException catch (e) {
      throw AuthServiceException(_extractDioMessage(e));
    } catch (_) {
      throw const AuthServiceException('Unexpected error while verifying OTP');
    }
  }

  Future<Map<String, dynamic>> submitClientOnboarding(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/onboarding/client',
        data: data,
      );
      return (response.data as Map).cast<String, dynamic>();
    } on AuthServiceException {
      rethrow;
    } on DioException catch (e) {
      throw AuthServiceException(_extractDioMessage(e));
    } catch (_) {
      throw const AuthServiceException('Unexpected error while submitting onboarding');
    }
  }

  String _extractDioMessage(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map && responseData['error'] != null) {
      return responseData['error'].toString();
    }
    return e.message ?? 'Network request failed';
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
