class Canal {
  final String id;
  final String nombre;
  final String urlStream;
  final String? thumbnail;

  Canal({required this.id, required this.nombre, required this.urlStream, this.thumbnail});

  factory Canal.fromJson(Map<String, dynamic> json) {
    return Canal(
      id: json['_id'],
      nombre: json['nombre'],
      urlStream: json['urlStream'],
      thumbnail: json['thumbnail'],
    );
  }
}