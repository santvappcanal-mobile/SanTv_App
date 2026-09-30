/// Lista única de categorías de SAN TV.
///
/// Para agregar o quitar una categoría solo se cambia esta lista:
/// Explorar y los formularios del admin se actualizan solos.
const List<String> kCategories = [
  'Todo',
  'Deportes',
  'Noticias',
  'Educación',
];

/// Categorías que el admin puede asignar a un video.
/// "Todo" no está: es solo un filtro, no una categoría real.
List<String> get kAssignableCategories => kCategories.skip(1).toList();

/// Normaliza un texto para comparar categorías sin importar
/// mayúsculas, minúsculas ni tildes ("Educación" == "educacion").
String normalizeCategory(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
}