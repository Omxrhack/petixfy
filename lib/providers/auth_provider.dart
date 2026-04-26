import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petixfy/models/user.dart';
import 'package:petixfy/network/api_client.dart';
import 'package:petixfy/services/auth_service.dart';
import 'package:petixfy/services/auth_state.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    FlutterSecureStorage? secureStorage,
  })  : _authService = authService ?? AuthService(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  User? currentUser;
  String? token;
  bool isLoading = false;
  String? errorMessage;

  /// Registro en backend; limpia sesión local y deja email pendiente de verificación OTP.
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(email, password);
      await _secureStorage.delete(key: ApiClient.accessTokenKey);
      await _secureStorage.delete(key: ApiClient.refreshTokenKey);
      await AppAuthState.clear();
      await AppAuthState.save(
        newEmail: email,
        newIsVerified: false,
        newOnboardingCompleted: false,
      );
      currentUser = null;
      token = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      currentUser = result.user;
      token = result.accessToken;

      await _secureStorage.write(
        key: ApiClient.accessTokenKey,
        value: result.accessToken,
      );

      if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
        await _secureStorage.write(
          key: ApiClient.refreshTokenKey,
          value: result.refreshToken,
        );
      }

      await AppAuthState.save(
        newAccessToken: result.accessToken,
        newRefreshToken: result.refreshToken,
        newEmail: result.user.email,
        newIsVerified: result.user.isVerified,
        newOnboardingCompleted: result.user.onboardingCompleted,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      currentUser = null;
      token = null;
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Tras [AuthApi.verifyOtp]: copia tokens a secure storage para que [ApiClient] envíe el Bearer.
  Future<void> adoptSessionFromVerify(Map<String, dynamic> data) async {
    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    final userJson = (data['user'] as Map?)?.cast<String, dynamic>();
    if (access == null || access.isEmpty || userJson == null) {
      return;
    }
    token = access;
    currentUser = User.fromJson(userJson);
    await _secureStorage.write(
      key: ApiClient.accessTokenKey,
      value: access,
    );
    if (refresh != null && refresh.isNotEmpty) {
      await _secureStorage.write(
        key: ApiClient.refreshTokenKey,
        value: refresh,
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    currentUser = null;
    token = null;
    errorMessage = null;
    await _secureStorage.delete(key: ApiClient.accessTokenKey);
    await _secureStorage.delete(key: ApiClient.refreshTokenKey);
    await AppAuthState.clear();
    notifyListeners();
  }

  Future<bool> submitClientOnboarding(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.submitClientOnboarding(data);
      if (currentUser != null) {
        currentUser = User(
          id: currentUser!.id,
          email: currentUser!.email,
          role: 'client',
          phone: currentUser!.phone,
          isVerified: currentUser!.isVerified,
          onboardingCompleted: true,
        );
      }
      final profile =
          (response['profile'] as Map?)?.cast<String, dynamic>();
      if (profile != null) {
        await AppAuthState.save(
          newOnboardingCompleted:
              profile['onboarding_completed'] as bool? ?? true,
          newIsVerified: profile['is_verified'] as bool? ?? AppAuthState.isVerified,
        );
      } else {
        await AppAuthState.save(newOnboardingCompleted: true);
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
