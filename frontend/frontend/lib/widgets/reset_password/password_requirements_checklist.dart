import 'package:flutter/material.dart';

/// Un requisito de contraseña: texto a mostrar + regla de validación.
class PasswordRule {
  const PasswordRule(this.label, this.isValid);
  final String label;
  final bool Function(String value) isValid;
}

/// Reglas estándar de contraseña, compartidas entre register y
/// reset password. Si tu register_screen ya tenía sus propias
/// reglas en widgets/register/password_requirements_checklist.dart,
/// compáralas con estas para no tener dos fuentes de verdad.
final List<PasswordRule> defaultPasswordRules = [
  PasswordRule('Mínimo 6 caracteres', (v) => v.length >= 6),
  PasswordRule('Al menos una letra', (v) => RegExp(r'[A-Za-z]').hasMatch(v)),
  PasswordRule('Al menos un número', (v) => RegExp(r'[0-9]').hasMatch(v)),
  PasswordRule(
    'Al menos un carácter especial (!@#\$%^&*.,_-)',
    (v) => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v),
  ),
];

/// Checklist animada que muestra en tiempo real cuáles reglas de
/// contraseña se cumplen. Aparece/desaparece según [visible].
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({
    super.key,
    required this.visible,
    required this.password,
    this.accentColor = const Color(0xFF39FF14),
    this.rules,
  });

  final bool visible;
  final String password;
  final Color accentColor;
  final List<PasswordRule>? rules;

  @override
  Widget build(BuildContext context) {
    final activeRules = rules ?? defaultPasswordRules;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: activeRules.map((rule) {
                  final ok = rule.isValid(password);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          ok ? Icons.check_circle : Icons.cancel_outlined,
                          size: 16,
                          color: ok ? accentColor : Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rule.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: ok ? Colors.white : Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}