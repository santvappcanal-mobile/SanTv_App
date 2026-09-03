import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_user.dart';

/// Resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;
  final AppUser? user;

  /// true cuando el registro (o intento de login) queda pendiente de
  /// verificar el código enviado al correo.
  final bool pendingVerification;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.token,
    this.user,
    this.pendingVerification = false,
  });
}

/// Servicio real de autenticación: habla con el backend de SanTv
/// (Node/Express) vía HTTP.
class AuthService {
  AuthService({required this.baseUrl});

  /// URL base de la API, ej: http://10.0.2.2:3000 (emulador Android)
  final String baseUrl;

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Uri _endpoint(String path) => Uri.parse('$baseUrl/api/users$path');

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['success'] == true) {
        return const AuthResult(success: true, pendingVerification: true);
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'No se pudo registrar',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>?;
        final token = data?['token']?.toString();
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          user: data != null ? AppUser.fromJson(data) : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'Código incorrecto',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future<AuthResult> resendCode({required String email}) async {
    try {
      final response = await http.post(
        _endpoint('/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'No se pudo reenviar el código',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      // Cuenta creada pero no verificada: el backend responde 403
      // con pendingVerification para que el frontend mande al usuario
      // a la pantalla de código en vez de mostrar un error genérico.
      if (response.statusCode == 403 && body['pendingVerification'] == true) {
        return AuthResult(
          success: false,
          pendingVerification: true,
          errorMessage: body['message']?.toString(),
        );
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>?;
        final token = data?['token']?.toString();
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          user: data != null ? AppUser.fromJson(data) : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'Credenciales incorrectas',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  /// Solicita el envío del código de recuperación al correo del usuario.
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        _endpoint('/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo enviar el código de recuperación',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  /// Confirma el código recibido por correo y establece la nueva contraseña.
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo restablecer la contraseña',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  /// Aún no configurado (requiere setup nativo de Google Sign-In).
  Future<AuthResult> loginWithGoogle() async {
    return const AuthResult(
      success: false,
      errorMessage: 'El inicio de sesión con Google todavía no está disponible.',
    );
  }

  /// Pide los datos del usuario logueado usando el token guardado.
  /// Úsalo al iniciar Home (o tras el login) para llenar el perfil
  /// con datos siempre frescos desde el backend.
  Future<AppUser?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        _endpoint('/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        return AppUser.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Actualiza nombre/email/avatar/password del usuario logueado.
  /// Usa el endpoint PUT /api/users/profile (protegido con el token).
  Future<AuthResult> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? password,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'No has iniciado sesión',
        );
      }

      final response = await http.put(
        _endpoint('/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (avatarUrl != null) 'avatar': avatarUrl,
          if (password != null) 'password': password,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>?;
        return AuthResult(
          success: true,
          user: data != null ? AppUser.fromJson(data) : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'No se pudo actualizar el perfil',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<bool> get isLoggedIn async => (await getToken()) != null;

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}