// Integrar en lib/services/auth_service.dart
// Requiere:  flutter pub add google_sign_in   (API 7.x: initialize + authenticate)
//
// Adapta lo marcado con (*) a lo que ya tienes en tu servicio:
//   (*) baseUrl, _storage, la key del token, AuthResult y AppUser.fromJson

import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// ID de cliente tipo "Web application" de Google Cloud Console.
// Es el MISMO valor que GOOGLE_CLIENT_ID en el .env del backend.
const String kGoogleWebClientId = 'TU_ID_WEB.apps.googleusercontent.com';

class AuthService {
  bool _googleReady = false;

  // initialize() se llama una sola vez antes de usar GoogleSignIn
  Future<void> _initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(serverClientId: kGoogleWebClientId);
    _googleReady = true;
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      await _initGoogle();

      // Abre el selector de cuentas de Google
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        return AuthResult(
          success: false,
          errorMessage: 'Google no devolvió el idToken. Revisa el serverClientId.',
        );
      }

      // Enviar el idToken al backend
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/login-google'), // (*)
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String;
        // (*) misma key con la que guardas el token en el login normal
        await _storage.write(key: 'token', value: token);
        return AuthResult(
          success: true,
          token: token,
          user: AppUser.fromJson(data['user']),
        );
      }

      return AuthResult(
        success: false,
        errorMessage: data['errorMessage'] ?? 'Error al iniciar sesión con Google',
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // OJO: en Android también aparece "canceled" cuando la configuración
        // es incorrecta (SHA-1 / package name / serverClientId) o si el
        // dispositivo no tiene una cuenta de Google.
        return AuthResult(
          success: false,
          errorMessage: 'Inicio de sesión cancelado',
        );
      }
      return AuthResult(
        success: false,
        errorMessage: 'Error de Google: ${e.code.name}',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor',
      );
    }
  }

  // Al cerrar sesión, cierra también la sesión de Google para que
  // la próxima vez vuelva a aparecer el selector de cuentas.
  Future<void> logout() async {
    await _initGoogle();
    await GoogleSignIn.instance.signOut();
    await _storage.delete(key: 'token'); // (*)
  }
}

// ─────────────────────────────────────────────────────────────
// Si tu pubspec tiene google_sign_in 6.x (API antigua), en vez de lo de arriba:
//
//   final g = GoogleSignIn(serverClientId: kGoogleWebClientId, scopes: ['email', 'profile']);
//   final acc = await g.signIn();                 // null si el usuario cancela
//   final idToken = (await acc!.authentication).idToken;
//   ...y el resto (POST al backend) es igual.
// ─────────────────────────────────────────────────────────────