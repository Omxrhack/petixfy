import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petixfy/models/user.dart';
import 'package:petixfy/network/api_client.dart';
import 'package:petixfy/services/auth_service.dart';
import 'package:petixfy/services/auth_state.dart';

/// Resultado de un intento de registro.
enum RegisterOutcome {
  /// Registro nuevo o reenvío de OTP a un usuario existente sin verificar.
  /// El cliente debe ir a la pantalla de OTP.
  goToOtp,

  /// El correo ya estaba registrado y verificado: el cliente debe ir al login.
  alreadyVerified,

  /// Supabase no envió el correo porque se agotó la cuota del SMTP.
  rateLimited,

  /// Falló el registro por otra razón (revisar [AuthProvider.errorMessage]).
  error,
}

/// Resultado de un reenvío de OTP.
enum ResendOtpOutcome {
  sent,
  rateLimited,
  error,
}

/// Resultado de un intento de login.
enum LoginOutcome {
  /// Login exitoso. La pantalla decide a dónde ir según el flag de onboarding.
  success,

  /// El correo no está confirmado todavía: ir a la pantalla de OTP.
  emailNotConfirmed,

  /// Supabase no pudo procesar la verificación porque se excedió la cuota de email.
  rateLimited,

  /// Credenciales inválidas u otro error: revisar [AuthProvider.errorMessage].
  error,
}

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

  /// Información extra del último intento de registro.
  bool lastRegisterResent = false;
  bool lastRegisterAlreadyExisted = false;

  /// Registro en backend; limpia sesión local y deja email pendiente de verificación OTP.
  ///
  /// - Si el correo es nuevo o existe pero no está verificado: [RegisterOutcome.goToOtp].
  /// - Si el correo ya está verificado: [RegisterOutcome.alreadyVerified].
  /// - Si hay otro error: [RegisterOutcome.error] (ver [errorMessage]).
  Future<RegisterOutcome> register({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    lastRegisterResent = false;
    lastRegisterAlreadyExisted = false;
    notifyListeners();

    try {
      final body = await _authService.register(email, password);
      lastRegisterResent = body['resent'] == true;
      lastRegisterAlreadyExisted = body['already_registered'] == true;

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
      return RegisterOutcome.goToOtp;
    } on AuthServiceException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      if (e.code == 'EMAIL_ALREADY_VERIFIED') {
        notifyListeners();
        return RegisterOutcome.alreadyVerified;
      }
      if (e.code == 'EMAIL_RATE_LIMIT') {
        notifyListeners();
        return RegisterOutcome.rateLimited;
      }
      notifyListeners();
      return RegisterOutcome.error;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return RegisterOutcome.error;
    }
  }

  /// Pide al backend reenviar el OTP de signup al correo dado.
  Future<ResendOtpOutcome> resendOtp(String email) async {
    errorMessage = null;
    try {
      await _authService.resendOtp(email);
      notifyListeners();
      return ResendOtpOutcome.sent;
    } on AuthServiceException catch (e) {
      errorMessage = e.message;
      if (e.code == 'EMAIL_RATE_LIMIT') {
        notifyListeners();
        return ResendOtpOutcome.rateLimited;
      }
      notifyListeners();
      return ResendOtpOutcome.error;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return ResendOtpOutcome.error;
    }
  }

  /// Email asociado al último intento de login (útil cuando el backend pide ir al OTP).
  String? lastLoginEmail;

  Future<LoginOutcome> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    lastLoginEmail = email;
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
      return LoginOutcome.success;
    } on AuthServiceException catch (e) {
      currentUser = null;
      token = null;
      isLoading = false;
      errorMessage = e.message;
      if (e.code == 'EMAIL_NOT_CONFIRMED') {
        // Guardamos el email para que la pantalla de OTP lo tenga aunque no haya sesión.
        await AppAuthState.save(
          newEmail: email,
          newIsVerified: false,
        );
        notifyListeners();
        return LoginOutcome.emailNotConfirmed;
      }
      if (e.code == 'EMAIL_RATE_LIMIT') {
        notifyListeners();
        return LoginOutcome.rateLimited;
      }
      notifyListeners();
      return LoginOutcome.error;
    } catch (e) {
      currentUser = null;
      token = null;
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return LoginOutcome.error;
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
