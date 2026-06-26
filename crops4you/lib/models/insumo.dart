class Insumo {
  final int? id;
  final int cultivoId;
  final String nombre;
  final String tipo;
  final double cantidad;
  final String unidad;
  final String fecha;
  final double? costo;
  final String? createdAt;

  Insumo({
    this.id,
    required this.cultivoId,
    required this.nombre,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.fecha,
    this.costo,
    this.createdAt,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) => Insumo(
    id: json['id'],
    cultivoId: json['cultivo_id'],
    nombre: json['nombre'],
    tipo: json['tipo'],
    cantidad: double.parse(json['cantidad'].toString()),
    unidad: json['unidad'],
    fecha: json['fecha'],
    costo: json['costo'] != null
        ? double.parse(json['costo'].toString())
        : null,
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'cultivo_id': cultivoId,
    'nombre': nombre,
    'tipo': tipo,
    'cantidad': cantidad,
    'unidad': unidad,
    'fecha': fecha,
    'costo': costo,
  };
}
