import 'package:flutter/material.dart';
import 'package:crops4you/main.dart';
import 'package:crops4you/models/cultivo.dart';
import 'package:crops4you/models/recordatorio.dart';
import 'package:crops4you/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  int _totalParcelas = 0;
  int _totalCultivos = 0;
  int _cultivosActivos = 0;
  List<Cultivo> _cultivosRecientes = [];
  List<Recordatorio> _recordatoriosPendientes = [];
  bool _loading = true;

  String get _nombreUsuario => _authService.getUserName();

  String get _inicial {
    if (_nombreUsuario.isEmpty) return 'U';
    return _nombreUsuario[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _loading = true);
    try {
      final parcelas = await supabase.from('parcelas').select();
      final cultivos = await supabase.from('cultivos').select();

      final recordatorios = await supabase
          .from('recordatorios')
          .select('*, cultivos(nombre, parcelas(nombre))')
          .eq('completado', false)
          .order('fecha_recordatorio')
          .limit(3);

      final recientes = await supabase
          .from('cultivos')
          .select('*, parcelas(nombre)')
          .order('created_at', ascending: false)
          .limit(3);

      setState(() {
        _totalParcelas = (parcelas as List).length;
        _totalCultivos = (cultivos as List).length;
        _cultivosActivos = (cultivos)
            .where((c) => c['estado'] == 'activo')
            .length;
        _cultivosRecientes = (recientes as List)
            .map((e) => Cultivo.fromJson(e))
            .toList();
        _recordatoriosPendientes = (recordatorios as List)
            .map((e) => Recordatorio.fromJson(e))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFF1D7F3C),
        onRefresh: _cargarDatos,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D7F3C), Color(0xFF145C2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _nombreUsuario,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB81C),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _inicial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '24°C',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Parcialmente nublado',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Humedad 65%',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Viento 12 km/h',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D7F3C),
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        _StatCard(
                          label: 'Parcelas',
                          valor: '$_totalParcelas',
                          icon: Icons.terrain,
                          color: const Color(0xFF1D7F3C),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Cultivos',
                          valor: '$_totalCultivos',
                          icon: Icons.eco,
                          color: const Color(0xFF1976D2),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Activos',
                          valor: '$_cultivosActivos',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFFFFB81C),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_recordatoriosPendientes.isNotEmpty) ...[
                      const _SectionTitle(titulo: 'Recordatorios pendientes'),
                      const SizedBox(height: 10),
                      ..._recordatoriosPendientes.map(
                        (r) => _RecordatorioCard(recordatorio: r),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const _SectionTitle(titulo: 'Cultivos recientes'),
                    const SizedBox(height: 10),
                    if (_cultivosRecientes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No hay cultivos registrados',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._cultivosRecientes.map(
                        (c) => _CultivoCard(cultivo: c),
                      ),
                    const SizedBox(height: 80),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.valor,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titulo;
  const _SectionTitle({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }
}

class _RecordatorioCard extends StatelessWidget {
  final Recordatorio recordatorio;
  const _RecordatorioCard({required this.recordatorio});

  Color get _color {
    final diferencia = recordatorio.fechaRecordatorio.difference(
      DateTime.now(),
    );
    if (diferencia.isNegative) return Colors.red;
    if (diferencia.inDays <= 2) return const Color(0xFFFFB81C);
    return const Color(0xFF1D7F3C);
  }

  String get _fechaTexto {
    final diferencia = recordatorio.fechaRecordatorio.difference(
      DateTime.now(),
    );
    final f = recordatorio.fechaRecordatorio;
    if (diferencia.isNegative) return 'Vencido · ${f.day}/${f.month}/${f.year}';
    if (diferencia.inDays == 0) {
      return 'Hoy · ${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
    }
    if (diferencia.inDays == 1) return 'Mañana · ${f.day}/${f.month}/${f.year}';
    return 'En ${diferencia.inDays} días · ${f.day}/${f.month}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: _color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recordatorio.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fechaTexto,
                  style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (recordatorio.nombreParcela != null ||
                    recordatorio.nombreCultivo != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (recordatorio.nombreParcela != null) ...[
                        const Icon(Icons.terrain, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          recordatorio.nombreParcela!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (recordatorio.nombreParcela != null &&
                          recordatorio.nombreCultivo != null)
                        const Text(
                          ' · ',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      if (recordatorio.nombreCultivo != null) ...[
                        const Icon(Icons.eco, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          recordatorio.nombreCultivo!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CultivoCard extends StatelessWidget {
  final Cultivo cultivo;
  const _CultivoCard({required this.cultivo});

  Color get _color {
    switch (cultivo.estado) {
      case 'activo':
        return const Color(0xFF1D7F3C);
      case 'cosechado':
        return const Color(0xFF1976D2);
      case 'perdido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _color,
            radius: 20,
            child: const Icon(Icons.eco, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cultivo.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (cultivo.nombreParcela != null)
                  Row(
                    children: [
                      const Icon(Icons.terrain, size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        cultivo.nombreParcela!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                Text(
                  'Siembra: ${cultivo.fechaSiembra}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cultivo.estado,
              style: TextStyle(
                color: _color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
