class Recordatorio {
  final int? id;
  final int cultivoId;
  final String titulo;
  final DateTime fechaRecordatorio;
  final bool completado;
  final String? createdAt;
  final String? nombreCultivo;
  final String? nombreParcela;

  Recordatorio({
    this.id,
    required this.cultivoId,
    required this.titulo,
    required this.fechaRecordatorio,
    this.completado = false,
    this.createdAt,
    this.nombreCultivo,
    this.nombreParcela,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
    id: json['id'],
    cultivoId: json['cultivo_id'],
    titulo: json['titulo'],
    fechaRecordatorio: DateTime.parse(json['fecha_recordatorio']),
    completado: json['completado'] ?? false,
    createdAt: json['created_at'],
    nombreCultivo: json['cultivos']?['nombre'],
    nombreParcela: json['cultivos']?['parcelas']?['nombre'],
  );

  Map<String, dynamic> toJson() => {
    'cultivo_id': cultivoId,
    'titulo': titulo,
    'fecha_recordatorio': fechaRecordatorio.toIso8601String(),
    'completado': completado,
  };

  Map<String, dynamic> toUpdateJson() => {
    'cultivo_id': cultivoId,
    'titulo': titulo,
    'fecha_recordatorio': fechaRecordatorio.toIso8601String(),
  };
}
