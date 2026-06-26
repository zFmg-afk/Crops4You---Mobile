class Parcela {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double? latitud; // centro del polígono
  final double? longitud; // centro del polígono
  final List<Map<String, double>>? poligono; // puntos del área
  final String? createdAt;

  Parcela({
    this.id,
    required this.nombre,
    this.descripcion,
    this.latitud,
    this.longitud,
    this.poligono,
    this.createdAt,
  });

  factory Parcela.fromJson(Map<String, dynamic> json) => Parcela(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
    latitud: json['latitud'] != null
        ? double.parse(json['latitud'].toString())
        : null,
    longitud: json['longitud'] != null
        ? double.parse(json['longitud'].toString())
        : null,
    poligono: json['poligono'] != null
        ? List<Map<String, double>>.from(
            (json['poligono'] as List).map(
              (p) => {
                'lat': double.parse(p['lat'].toString()),
                'lng': double.parse(p['lng'].toString()),
              },
            ),
          )
        : null,
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'latitud': latitud,
    'longitud': longitud,
    'poligono': poligono,
  };
}
