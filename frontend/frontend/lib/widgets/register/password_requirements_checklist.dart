import 'package:flutter/material.dart';

/// Un requisito de la contraseña: texto a mostrar + regla de validación.
class PasswordRule {
  const PasswordRule(this.label, this.isValid);
  final String label;
  final bool Function(String value) isValid;
}

class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({
    super.key,
    required this.visible,
    required this.rules,
    required this.currentValue,
    required this.accentColor,
  });

  final bool visible;
  final List<PasswordRule> rules;
  final String currentValue;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: rules.map((rule) {
                  final ok = rule.isValid(currentValue);
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