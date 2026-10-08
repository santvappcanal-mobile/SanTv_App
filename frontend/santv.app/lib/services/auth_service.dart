import 'dart:convert';
import 'dart:io';
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

  /// Tiempo máximo de espera para peticiones normales.
  static const _timeout = Duration(seconds: 15);

  /// Tiempo máximo para validar la sesión al arrancar la app.
  static const _profileTimeout = Duration(seconds: 8);

  /// Tiempo máximo para subir la foto de perfil (archivo más pesado).
  static const _uploadTimeout = Duration(seconds: 60);

  // ID de cliente tipo "Web application" de Google Cloud Console.
  // Debe ser el MISMO valor que GOOGLE_CLIENT_ID en el .env del backend.
  // El secreto del cliente NO va en la app.
  static const _googleWebClientId =
      '1057846858411-m66khkt1n9jh92pr57eggg4mtov2o9v6.apps.googleusercontent.com';

  // static porque AuthService se instancia varias veces y
  // GoogleSignIn.instance.initialize() solo debe llamarse una vez.
  static bool _googleReady = false;

  Uri _endpoint(String path) => Uri.parse('$baseUrl/api/users$path');

  Future<void> _initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(serverClientId: _googleWebClientId);
    _googleReady = true;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            _endpoint('/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'name': name, 'email': email, 'password': password}),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            _endpoint('/verify-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data']; // dynamic
        final token = data?['token']?.toString();
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return AuthResult(
          success: true,
          token: token,
          // Casting seguro para evitar el error de Map
          user: data != null
              ? AppUser.fromJson(Map<String, dynamic>.from(data))
              : null,
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
      final response = await http
          .post(
            _endpoint('/resend-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            _endpoint('/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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
          // Casting seguro
          user: data != null
              ? AppUser.fromJson(Map<String, dynamic>.from(data))
              : null,
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

  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await http
          .post(
            _endpoint('/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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

  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            _endpoint('/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'newPassword': newPassword,
            }),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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

  Future<AuthResult> loginWithGoogle() async {
    try {
      await _initGoogle();

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        return const AuthResult(
          success: false,
          errorMessage:
              'Google no devolvió el idToken. Revisa el serverClientId.',
        );
      }

      final response = await http
          .post(
            _endpoint('/login-google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(_timeout);

      debugPrint(
        'LOGIN-GOOGLE backend -> ${response.statusCode}:${response.body}',
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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
          // Casting seguro
          user: userJson != null
              ? AppUser.fromJson(Map<String, dynamic>.from(userJson))
              : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudo iniciar sesión con Google',
      );
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GOOGLE ERROR -> code: ${e.code.name}, description: ${e.description}',
      );

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return AuthResult(
          success: false,
          errorMessage:
              'Inicio de sesión cancelado (${e.description ?? 'sin detalle'})',
        );
      }
      return AuthResult(
        success: false,
        errorMessage: 'Error de Google: ${e.code.name} ${e.description ?? ''}'
            .trim(),
      );
    } catch (e) {
      debugPrint('LOGIN-GOOGLE error inesperado -> $e');
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

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
      ).timeout(_profileTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        // Casting seguro
        return AppUser.fromJson(Map<String, dynamic>.from(body['data']));
      }
      return null;
    } catch (_) {
      // Incluye TimeoutException: si el backend no responde, se trata como
      // "sin sesión válida" para que la app no se quede cargando.
      return null;
    }
  }

  /// Actualiza el perfil. Para el avatar:
  ///  - avatarUrl: 'avatar:3' -> avatar prediseñado
  ///  - avatarUrl: ''         -> quitar foto/avatar
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

      final response = await http
          .put(
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
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        return AuthResult(
          success: true,
          // Casting seguro
          user: data != null
              ? AppUser.fromJson(Map<String, dynamic>.from(data))
              : null,
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

  /// Sube una foto de perfil (multipart, campo "foto") y devuelve el
  /// usuario actualizado con la URL de Cloudinary.
  Future<AuthResult> uploadProfilePhoto(File file) async {
    try {
      final token = await getToken();
      if (token == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'No has iniciado sesión',
        );
      }

      final request = http.MultipartRequest('POST', _endpoint('/profile/photo'))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('foto', file.path));

      final streamed = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        return AuthResult(
          success: true,
          user: data != null
              ? AppUser.fromJson(Map<String, dynamic>.from(data))
              : null,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'No se pudo subir la foto',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  /// Avisa al backend que el usuario sigue dentro de la app.
  Future<void> ping() async {
    try {
      final token = await getToken();
      if (token == null) return;
      await http.put(
        _endpoint('/ping'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
    } catch (_) {}
  }

  /// Avisa al backend que el usuario salió (segundo plano / logout).
  Future<void> setOffline() async {
    try {
      final token = await getToken();
      if (token == null) return;
      await http.put(
        _endpoint('/offline'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
    } catch (_) {}
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<bool> get isLoggedIn async => (await getToken()) != null;

  Future<void> logout() async {
    await setOffline(); // debe ir antes de borrar el token
    await _storage.delete(key: _tokenKey);

    try {
      await _initGoogle();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}