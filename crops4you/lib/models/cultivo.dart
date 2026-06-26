class Cultivo {
  final int? id;
  final int parcelaId;
  final String nombre;
  final String fechaSiembra;
  final String estado;
  final String? notas;
  final String? createdAt;
  final String? nombreParcela;

  Cultivo({
    this.id,
    required this.parcelaId,
    required this.nombre,
    required this.fechaSiembra,
    this.estado = 'activo',
    this.notas,
    this.createdAt,
    this.nombreParcela,
  });

  factory Cultivo.fromJson(Map<String, dynamic> json) => Cultivo(
    id: json['id'],
    parcelaId: json['parcela_id'],
    nombre: json['nombre'],
    fechaSiembra: json['fecha_siembra'],
    estado: json['estado'] ?? 'activo',
    notas: json['notas'],
    createdAt: json['created_at'],
    nombreParcela: json['parcelas']?['nombre'],
  );

  Map<String, dynamic> toJson() => {
    'parcela_id': parcelaId,
    'nombre': nombre,
    'fecha_siembra': fechaSiembra,
    'estado': estado,
    'notas': notas,
  };
}
