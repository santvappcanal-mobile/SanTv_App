/// Plan de publicidad que el cliente puede contratar.
class AdPlan {
  const AdPlan({
    required this.name,
    required this.price,
    required this.description,
  });

  final String name;
  final double price;
  final String description;
}

// TODO: reemplaza por los planes y precios reales de la propuesta.
const List<AdPlan> adPlans = [
  AdPlan(
    name: 'Plan Básico',
    price: 150000,
    description: 'Pauta en banner dentro de la app',
  ),
  AdPlan(
    name: 'Plan Estándar',
    price: 300000,
    description: 'Banner + anuncio emergente',
  ),
  AdPlan(
    name: 'Plan Premium',
    price: 500000,
    description: 'Video publicitario + banner + anuncio emergente',
  ),
];

/// Formatea un valor en pesos: 150000 -> $150.000
String formatCop(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '\$$buf';
}
