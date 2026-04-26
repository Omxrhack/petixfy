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

  /// Registro: el backend responde 201 sin tokens; el usuario debe verificar OTP.
  /// Devuelve el cuerpo de la respuesta (puede incluir `already_registered`).
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = response.data;
      if (data is Map) {
        return data.cast<String, dynamic>();
      }
      return <String, dynamic>{};
    } on AuthServiceException {
      rethrow;
    } on DioException catch (e) {
      throw AuthServiceException(
        _extractDioMessage(e),
        code: _extractDioCode(e),
        statusCode: e.response?.statusCode,
        data: _extractDioData(e),
      );
    } catch (_) {
      throw const AuthServiceException('Unexpected error while registering');
    }
  }

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
      throw AuthServiceException(
        _extractDioMessage(e),
        code: _extractDioCode(e),
        statusCode: e.response?.statusCode,
        data: _extractDioData(e),
      );
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
      throw AuthServiceException(
        _extractDioMessage(e),
        code: _extractDioCode(e),
        statusCode: e.response?.statusCode,
        data: _extractDioData(e),
      );
    } catch (_) {
      throw const AuthServiceException('Unexpected error while verifying OTP');
    }
  }

  /// Pide explícitamente al backend que reenvíe el OTP de signup al correo.
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/resend-otp',
        data: {'email': email},
      );
      final data = response.data;
      if (data is Map) {
        return data.cast<String, dynamic>();
      }
      return <String, dynamic>{};
    } on AuthServiceException {
      rethrow;
    } on DioException catch (e) {
      throw AuthServiceException(
        _extractDioMessage(e),
        code: _extractDioCode(e),
        statusCode: e.response?.statusCode,
        data: _extractDioData(e),
      );
    } catch (_) {
      throw const AuthServiceException('Unexpected error while resending OTP');
    }
  }

  Future<Map<String, dynamic>> submitClientOnboarding(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/onboarding',
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

  String? _extractDioCode(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map && responseData['code'] != null) {
      return responseData['code'].toString();
    }
    return null;
  }

  Map<String, dynamic>? _extractDioData(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map) {
      return responseData.cast<String, dynamic>();
    }
    return null;
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message, {this.code, this.statusCode, this.data});
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() => message;
}
