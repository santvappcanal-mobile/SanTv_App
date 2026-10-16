import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Pantalla para editar los datos del perfil (por ahora, el nombre).
/// El correo se muestra pero no se puede cambiar.
///
/// [onSaved] se llama con el usuario ya actualizado, para que la pantalla
/// que la abrió (Configuración / Perfil) refresque sus datos.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.authService,
    required this.user,
    required this.onSaved,
  });

  final AuthService authService;
  final AppUser user;
  final void Function(AppUser updated) onSaved;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF1A1A1A);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _guardando = false;

  // Solo letras (con tildes y ñ) y espacios
  static final RegExp _soloLetras = RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validarNombre(String? value) {
    final texto = (value ?? '').trim();
    if (texto.isEmpty) return 'Escribe tu nombre';
    if (texto.length < 2) return 'El nombre es demasiado corto';
    if (!_soloLetras.hasMatch(texto)) return 'Solo se permiten letras';
    return null;
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final nuevoNombre = _nameController.text.trim();

    // Sin cambios: solo se cierra la pantalla
    if (nuevoNombre == widget.user.name) {
      Navigator.pop(context);
      return;
    }

    setState(() => _guardando = true);

    // NOTA: si tu AuthService.updateProfile recibe otros parámetros, ajusta SOLO esta línea.
    final result = await widget.authService.updateProfile(name: nuevoNombre);

    if (!mounted) return;

    if (!result.success) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'No se pudo guardar el perfil'),
        ),
      );
      return;
    }

    // Si la respuesta no trae el usuario, se vuelve a pedir el perfil
    final actualizado = result.user ?? await widget.authService.getProfile();

    if (!mounted) return;
    setState(() => _guardando = false);

    if (actualizado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se guardó, pero no se pudo recargar el perfil')),
      );
      return;
    }

    widget.onSaved(actualizado);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inicial = widget.user.name.trim().isNotEmpty
        ? widget.user.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar perfil', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar con la inicial del nombre
              Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: neonGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: neonGreen, width: 1.5),
                ),
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: neonGreen,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Nombre (editable)
              TextFormField(
                controller: _nameController,
                enabled: !_guardando,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white),
                validator: _validarNombre,
                decoration: _decoracion('Nombre', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              // Correo (solo lectura)
              TextFormField(
                initialValue: widget.user.email,
                enabled: false,
                style: const TextStyle(color: Colors.white54),
                decoration: _decoracion('Correo electrónico', Icons.mail_outline),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    disabledBackgroundColor: neonGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icono, color: neonGreen),
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: neonGreen),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}