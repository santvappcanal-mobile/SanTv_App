import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

/// Resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;
  final AppUser? user;
  final bool pendingVerification;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.token,
    this.user,
    this.pendingVerification = false,
  });
}

/// Servicio real de autenticación.
class AuthService {
  AuthService({this.baseUrl = 'http://10.0.2.2:3000'});

  final String baseUrl;

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static const _googleWebClientId =
      '1057846858411-m66khkt1n9jh92pr57eggg4mtov2o9v6.apps.googleusercontent.com';

  static bool _googleReady = false;

  /// Valida y sanitiza la URL para evitar errores de URI sin host
  Uri _endpoint(String path) {
    String url = baseUrl.trim();

    // Si la URL está vacía o es la palabra literal 'baseUrl', asigna la IP del emulador
    if (url.isEmpty || url == 'baseUrl') {
      url = 'http://10.0.2.2:3000';
    }

    // Agrega http:// si no tiene esquema
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Quita la barra al final si existe
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return Uri.parse('\(url/api/users\)path');
  }

  Future _initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(serverClientId: _googleWebClientId);
    _googleReady = true;
  }

  Future register({
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

      final body = jsonDecode(response.body) as Map;

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

  Future verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final token = data?['token']?.toString();
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          user: data != null ? AppUser.fromJson(Map.from(data)) : null,
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

  Future resendCode({required String email}) async {
    try {
      final response = await http.post(
        _endpoint('/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo reenviar el código',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 403 && body['pendingVerification'] == true) {
        return AuthResult(
          success: false,
          pendingVerification: true,
          errorMessage: body['message']?.toString(),
        );
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final token = data?['token']?.toString();
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          user: data != null ? AppUser.fromJson(Map.from(data)) : null,
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

  Future forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        _endpoint('/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudo enviar el código de recuperación',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future resetPassword({
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

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudo restablecer la contraseña',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future loginWithGoogle() async {
    try {
      await _initGoogle();

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account?.authentication.idToken;

      if (idToken == null) {
        return const AuthResult(
          success: false,
          errorMessage:
              'Google no devolvió el idToken. Revisa el serverClientId.',
        );
      }

      final response = await http.post(
        _endpoint('/login-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final userJson = data ?? body['user'];
        final token = (data?['token'] ?? body['token'])?.toString();

        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          user: userJson != null ? AppUser.fromJson(Map.from(userJson)) : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudo iniciar sesión con Google',
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return AuthResult(
          success: false,
          errorMessage:
              'Inicio de sesión cancelado (${e.description ?? 'sin detalle'})',
        );
      }
      return AuthResult(
        success: false,
        errorMessage: 'Error de Google: \({e.code.name}\){e.description ?? ''}'
            .trim(),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future getProfile() async {
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

      final body = jsonDecode(response.body) as Map;
      if (response.statusCode == 200 && body['success'] == true) {
        return AppUser.fromJson(Map.from(body['data']));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future updateProfile({
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

      final body = jsonDecode(response.body) as Map;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        return AuthResult(
          success: true,
          user: data != null ? AppUser.fromJson(Map.from(data)) : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo actualizar el perfil',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future getToken() async => _storage.read(key: _tokenKey);

  Future get isLoggedIn async => (await getToken()) != null;

  Future logout() async {
    await _storage.delete(key: _tokenKey);

    try {
      await _initGoogle();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}