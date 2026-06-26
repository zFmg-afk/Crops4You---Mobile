import 'package:flutter/material.dart';
import 'package:crops4you/models/cultivo.dart';
import 'package:crops4you/models/actividad.dart';
import 'package:crops4you/models/insumo.dart';
import 'package:crops4you/services/actividad_service.dart';
import 'package:crops4you/services/insumo_service.dart';
import 'package:crops4you/screens/actividades/actividad_form_screen.dart';
import 'package:crops4you/screens/insumos/insumo_form_screen.dart';
import 'package:crops4you/screens/recordatorios/recordatorios_screen.dart';

class CultivoDetalleScreen extends StatefulWidget {
  final Cultivo cultivo;
  const CultivoDetalleScreen({super.key, required this.cultivo});

  @override
  State<CultivoDetalleScreen> createState() => _CultivoDetalleScreenState();
}

class _CultivoDetalleScreenState extends State<CultivoDetalleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _actividadService = ActividadService();
  final _insumoService = InsumoService();
  List<Actividad> _actividades = [];
  List<Insumo> _insumos = [];
  bool _loadingAct = true;
  bool _loadingIns = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargarActividades();
    _cargarInsumos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarActividades() async {
    setState(() => _loadingAct = true);
    try {
      final data = await _actividadService.getByCultivo(widget.cultivo.id!);
      setState(() {
        _actividades = data;
        _loadingAct = false;
      });
    } catch (e) {
      setState(() => _loadingAct = false);
    }
  }

  Future<void> _cargarInsumos() async {
    setState(() => _loadingIns = true);
    try {
      final data = await _insumoService.getByCultivo(widget.cultivo.id!);
      setState(() {
        _insumos = data;
        _loadingIns = false;
      });
    } catch (e) {
      setState(() => _loadingIns = false);
    }
  }

  Future<void> _toggleCompletarActividad(Actividad a) async {
    try {
      if (a.completado) {
        await _actividadService.desmarcar(a.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Actividad marcada como pendiente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _actividadService.completar(a.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Actividad completada'),
              backgroundColor: Color(0xFF1D7F3C),
            ),
          );
        }
      }
      _cargarActividades();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _eliminarActividad(Actividad a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: Text('¿Eliminar esta actividad de "${a.tipo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true && a.id != null) {
      await _actividadService.delete(a.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cargarActividades();
    }
  }

  Future<void> _eliminarInsumo(Insumo ins) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar insumo'),
        content: Text('¿Eliminar "${ins.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true && ins.id != null) {
      await _insumoService.delete(ins.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insumo eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cargarInsumos();
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
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

  IconData _tipoActividadIcon(String tipo) {
    switch (tipo) {
      case 'riego':
        return Icons.water_drop;
      case 'fertilizacion':
        return Icons.science;
      case 'fumigacion':
        return Icons.pest_control;
      case 'cosecha':
        return Icons.agriculture;
      case 'siembra':
        return Icons.grass;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cultivo;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            tooltip: 'Recordatorios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RecordatoriosScreen(cultivoId: widget.cultivo.id),
              ),
            ),
          ),
        ],
        title: Text(c.nombre),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Actividades'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Insumos'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_tabController.index == 0) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActividadFormScreen(cultivoId: c.id!),
              ),
            );
            _cargarActividades();
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InsumoFormScreen(cultivoId: c.id!),
              ),
            );
            _cargarInsumos();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0 ? 'Nueva actividad' : 'Nuevo insumo',
        ),
      ),
      body: Column(
        children: [
          // Info resumen del cultivo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _estadoColor(c.estado),
                  radius: 28,
                  child: const Icon(Icons.eco, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Siembra: ${c.fechaSiembra}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      if (c.notas != null && c.notas!.isNotEmpty)
                        Text(
                          c.notas!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _estadoColor(c.estado).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.estado,
                    style: TextStyle(
                      color: _estadoColor(c.estado),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs de contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1 — Actividades
                _loadingAct
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D7F3C),
                        ),
                      )
                    : _actividades.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sin actividades registradas',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _actividades.length,
                        itemBuilder: (context, i) {
                          final a = _actividades[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: a.completado
                                    ? Colors.grey.withOpacity(0.12)
                                    : const Color(0xFF1D7F3C).withOpacity(0.12),
                                child: Icon(
                                  _tipoActividadIcon(a.tipo),
                                  color: a.completado
                                      ? Colors.grey
                                      : const Color(0xFF1D7F3C),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                a.tipo.substring(0, 1).toUpperCase() +
                                    a.tipo.substring(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: a.completado
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: a.completado
                                      ? Colors.grey
                                      : const Color(0xFF333333),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.fecha,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: a.completado
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  if (a.descripcion != null &&
                                      a.descripcion!.isNotEmpty)
                                    Text(
                                      a.descripcion!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: a.completado
                                            ? Colors.grey
                                            : Colors.black87,
                                        decoration: a.completado
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      a.completado
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: a.completado
                                          ? const Color(0xFF1D7F3C)
                                          : Colors.grey,
                                    ),
                                    tooltip: a.completado
                                        ? 'Marcar como pendiente'
                                        : 'Marcar como completada',
                                    onPressed: () =>
                                        _toggleCompletarActividad(a),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _eliminarActividad(a),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // Tab 2 — Insumos
                _loadingIns
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D7F3C),
                        ),
                      )
                    : _insumos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sin insumos registrados',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _insumos.length,
                        itemBuilder: (context, i) {
                          final ins = _insumos[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(
                                  0xFFFFB81C,
                                ).withOpacity(0.15),
                                child: const Icon(
                                  Icons.science,
                                  color: Color(0xFFFFB81C),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                ins.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${ins.tipo} · ${ins.cantidad} ${ins.unidad} · ${ins.fecha}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (ins.costo != null)
                                    Text(
                                      '\$${ins.costo!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFF1D7F3C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _eliminarInsumo(ins),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
