class Actividad {
  final int? id;
  final int cultivoId;
  final String tipo;
  final String fecha;
  final String? descripcion;
  final bool completado;
  final String? createdAt;

  Actividad({
    this.id,
    required this.cultivoId,
    required this.tipo,
    required this.fecha,
    this.descripcion,
    this.completado = false,
    this.createdAt,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) => Actividad(
    id: json['id'],
    cultivoId: json['cultivo_id'],
    tipo: json['tipo'],
    fecha: json['fecha'],
    descripcion: json['descripcion'],
    completado: json['completado'] ?? false,
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'cultivo_id': cultivoId,
    'tipo': tipo,
    'fecha': fecha,
    'descripcion': descripcion,
    'completado': completado,
  };
}
