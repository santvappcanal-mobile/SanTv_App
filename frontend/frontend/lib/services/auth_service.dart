import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_user.dart';

/// Resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final AppUser? user;
  final String? token;

  /// true cuando el registro fue exitoso pero falta verificar el
  /// código enviado al correo (siguiente paso: pantalla de código).
  final bool pendingVerification;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.token,
    this.pendingVerification = false,
  });
}

/// Servicio de autenticación: registro/login con email y contraseña,
/// login con Google, verificación de código y manejo de sesión (JWT).
///
/// Backend esperado (REST):
///   POST /auth/register       { name, email, password } -> pendingVerification
///   POST /auth/verify-code    { email, code }            -> { token, user }
///   POST /auth/resend-code    { email }                  -> ok
///   POST /auth/login          { email, password }        -> { token, user }
///   POST /auth/google         { idToken }                -> { token, user }
///
/// Nota: al venir de Google el correo ya está verificado, por lo que
/// ese flujo NO pasa por la pantalla de código.
class AuthService {
  AuthService({required this.baseUrl});

  /// URL base de tu API, ej: https://api.santv.com
  final String baseUrl;

  final _storage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  static const _tokenKey = 'santv_auth_token';

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// Registra un usuario nuevo. El backend debe enviar un código de
  /// verificación al email indicado.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        _u('/auth/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return const AuthResult(success: true, pendingVerification: true);
      }
      return AuthResult(success: false, errorMessage: _errorFrom(res));
    } catch (_) {
      return const AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  /// Verifica el código enviado por correo al registrarse.
  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final res = await http.post(
        _u('/auth/verify-code'),
        headers: _headers,
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (res.statusCode == 200) return _saveSession(res);
      return AuthResult(success: false, errorMessage: _errorFrom(res));
    } catch (_) {
      return const AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  /// Reenvía el código de verificación al correo del usuario.
  Future<bool> resendCode(String email) async {
    try {
      final res = await http.post(
        _u('/auth/resend-code'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        _u('/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) return _saveSession(res);
      return AuthResult(success: false, errorMessage: _errorFrom(res));
    } catch (_) {
      return const AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  /// Inicia sesión (o crea cuenta) con Google.
  Future<AuthResult> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'Inicio de sesión con Google cancelado.',
        );
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'No se pudo obtener el token de Google.',
        );
      }

      final res = await http.post(
        _u('/auth/google'),
        headers: _headers,
        body: jsonEncode({'idToken': idToken}),
      );

      if (res.statusCode == 200) return _saveSession(res);
      return AuthResult(success: false, errorMessage: _errorFrom(res));
    } catch (_) {
      return const AuthResult(
        success: false,
        errorMessage: 'No se pudo iniciar sesión con Google.',
      );
    }
  }

  Future<AuthResult> _saveSession(http.Response res) async {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = body['token']?.toString();
    final user = body['user'] is Map
        ? AppUser.fromJson(Map<String, dynamic>.from(body['user']))
        : null;

    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }

    return AuthResult(success: true, token: token, user: user);
  }

  String _errorFrom(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['message']?.toString() ??
          'Ocurrió un error. Intenta de nuevo.';
    } catch (_) {
      return 'Ocurrió un error. Intenta de nuevo.';
    }
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<bool> get isLoggedIn async => (await getToken()) != null;

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _googleSignIn.signOut();
  }
}