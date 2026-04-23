import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petixfy/models/user.dart';
import 'package:petixfy/network/api_client.dart';
import 'package:petixfy/services/auth_service.dart';

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

  Future<void> signOut() async {
    currentUser = null;
    token = null;
    errorMessage = null;
    await _secureStorage.delete(key: ApiClient.accessTokenKey);
    await _secureStorage.delete(key: ApiClient.refreshTokenKey);
    notifyListeners();
  }

  Future<bool> submitClientOnboarding(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.submitClientOnboarding(data);
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
