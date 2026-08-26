/// Resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;

  /// true cuando el registro fue exitoso pero falta verificar el
  /// código enviado al correo (siguiente paso: pantalla de código).
  final bool pendingVerification;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.token,
    this.pendingVerification = false,
  });
}

/// ---------------------------------------------------------------
/// VERSIÓN TEMPORAL / SIMULADA de AuthService.
///
/// No depende de http, google_sign_in ni flutter_secure_storage, para
/// que el proyecto compile mientras aún no instalas esos paquetes ni
/// tienes el backend conectado.
///
/// Misma interfaz pública que la versión real (register, login,
/// loginWithGoogle, verifyCode, resendCode, logout, isLoggedIn), así
/// que tus pantallas (LoginScreen, RegisterScreen, AuthScreen) NO
/// necesitan ningún cambio cuando reemplaces esto por la versión real.
///
/// Para pasar a la versión real más adelante:
///   1) flutter pub add http google_sign_in flutter_secure_storage
///   2) Reemplaza este archivo por la versión con llamadas HTTP reales.
/// ---------------------------------------------------------------
class AuthService {
  AuthService({this.baseUrl = ''});

  /// URL base de tu API (no se usa todavía en esta versión simulada).
  final String baseUrl;

  String? _fakeToken;
  String? _pendingEmail;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        errorMessage: 'Completa todos los campos.',
      );
    }

    _pendingEmail = email;
    return const AuthResult(success: true, pendingVerification: true);
  }

  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (code != '1234') {
      return const AuthResult(
        success: false,
        errorMessage: 'Código incorrecto (usa 1234 en modo simulado).',
      );
    }

    _fakeToken = 'fake_token_$email';
    return AuthResult(success: true, token: _fakeToken);
  }

  Future<bool> resendCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        errorMessage: 'Credenciales incorrectas',
      );
    }

    _fakeToken = 'fake_token_$email';
    return AuthResult(success: true, token: _fakeToken);
  }

  Future<AuthResult> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _fakeToken = 'fake_google_token';
    return AuthResult(success: true, token: _fakeToken);
  }

  Future<String?> getToken() async => _fakeToken;

  Future<bool> get isLoggedIn async => _fakeToken != null;

  Future<void> logout() async {
    _fakeToken = null;
  }
}