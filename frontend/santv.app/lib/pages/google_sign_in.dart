import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// ID de cliente tipo "Aplicación web". Es el MISMO valor que
// GOOGLE_CLIENT_ID en el .env del backend. El secreto NO va aquí.
const String kGoogleWebClientId =
    '1057846858411-m66khkt1n9jh92pr57eggg4mtov2o9v6.apps.googleusercontent.com';

// Dentro de class AuthService { ... }

bool _googleReady = false;

Future<void> _initGoogle() async {
  if (_googleReady) return;
  await GoogleSignIn.instance.initialize(serverClientId: kGoogleWebClientId);
  _googleReady = true;
}

Future<AuthResult> loginWithGoogle() async {
  try {
    await _initGoogle();

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null) {
      return AuthResult(
        success: false,
        errorMessage: 'Google no devolvió el idToken. Revisa el serverClientId.',
      );
    }

    final res = await http.post(
      Uri.parse('$baseUrl/api/users/login-google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 200 && data['success'] == true) {
      final token = data['token'] as String;
      await _storage.write(key: 'auth_token', value: token); // misma key que main.dart
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
      // En Android también aparece "canceled" si falta el SHA-1, el
      // package name está mal o el emulador no tiene cuenta de Google.
      return AuthResult(success: false, errorMessage: 'Inicio de sesión cancelado');
    }
    return AuthResult(success: false, errorMessage: 'Error de Google: ${e.code.name}');
  } catch (e) {
    return AuthResult(success: false, errorMessage: 'No se pudo conectar con el servidor');
  }
}

// Reemplaza tu logout() actual por este (o agrega estas dos líneas al tuyo):
Future<void> logout() async {
  await _initGoogle();
  await GoogleSignIn.instance.signOut();
  await _storage.delete(key: 'auth_token');
}