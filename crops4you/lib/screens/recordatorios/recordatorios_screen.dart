import 'package:flutter/material.dart';
import 'package:crops4you/models/recordatorio.dart';
import 'package:crops4you/services/recordatorio_service.dart';
import 'package:crops4you/screens/recordatorios/recordatorio_form_screen.dart';

class RecordatoriosScreen extends StatefulWidget {
  final int? cultivoId;
  const RecordatoriosScreen({super.key, this.cultivoId});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen>
    with SingleTickerProviderStateMixin {
  final _service = RecordatorioService();
  late TabController _tabController;
  List<Recordatorio> _pendientes = [];
  List<Recordatorio> _completados = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final todos = widget.cultivoId != null
          ? await _service.getByCultivo(widget.cultivoId!)
          : await _service.getAll();

      setState(() {
        _pendientes = todos.where((r) => !r.completado).toList();
        _completados = todos.where((r) => r.completado).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar recordatorios: $e')),
        );
      }
    }
  }

  Future<void> _completar(Recordatorio r) async {
    await _service.completar(r.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recordatorio completado'),
          backgroundColor: Color(0xFF1D7F3C),
        ),
      );
    }
    _cargar();
  }

  Future<void> _eliminar(Recordatorio r) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: Text('¿Eliminar "${r.titulo}"?'),
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
    if (confirmar == true) {
      await _service.delete(r.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cargar();
    }
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora);

    if (diferencia.isNegative) {
      return 'Vencido · ${fecha.day}/${fecha.month}/${fecha.year}';
    } else if (diferencia.inDays == 0) {
      return 'Hoy · ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Mañana · ${fecha.day}/${fecha.month}/${fecha.year}';
    } else {
      return 'En ${diferencia.inDays} días · ${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  Color _fechaColor(DateTime fecha) {
    final diferencia = fecha.difference(DateTime.now());
    if (diferencia.isNegative) return Colors.red;
    if (diferencia.inDays <= 2) return const Color(0xFFFFB81C);
    return const Color(0xFF1D7F3C);
  }

  Widget _listaRecordatorios(List<Recordatorio> lista, bool esPendiente) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esPendiente ? Icons.alarm_off : Icons.check_circle_outline,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              esPendiente
                  ? 'No hay recordatorios pendientes'
                  : 'No hay recordatorios completados',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: lista.length,
      itemBuilder: (context, i) {
        final r = lista[i];
        final color = esPendiente
            ? _fechaColor(r.fechaRecordatorio)
            : Colors.grey;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                esPendiente ? Icons.alarm : Icons.check_circle,
                color: color,
                size: 24,
              ),
            ),
            title: Text(
              r.titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: esPendiente
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
                color: esPendiente ? const Color(0xFF333333) : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFecha(r.fechaRecordatorio),
                  style: TextStyle(
                    fontSize: 12,
                    color: esPendiente ? color : Colors.grey,
                    fontWeight: esPendiente
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                // Parcela y cultivo
                if (r.nombreParcela != null || r.nombreCultivo != null)
                  Row(
                    children: [
                      if (r.nombreParcela != null) ...[
                        const Icon(Icons.terrain, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          r.nombreParcela!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (r.nombreParcela != null && r.nombreCultivo != null)
                        const Text(
                          ' · ',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      if (r.nombreCultivo != null) ...[
                        const Icon(Icons.eco, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          r.nombreCultivo!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            trailing: esPendiente
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton(
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (v) async {
                          if (v == 'editar') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecordatorioFormScreen(recordatorio: r),
                              ),
                            );
                            _cargar();
                          } else if (v == 'eliminar') {
                            _eliminar(r);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF1D7F3C),
                        ),
                        tooltip: 'Marcar como completado',
                        onPressed: () => _completar(r),
                      ),
                    ],
                  )
                : PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (v) {
                      if (v == 'eliminar') _eliminar(r);
                    },
                    child: const Icon(Icons.more_vert),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm, size: 18),
                  const SizedBox(width: 6),
                  Text('Pendientes (${_pendientes.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 6),
                  Text('Completados (${_completados.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RecordatorioFormScreen(cultivoId: widget.cultivoId),
            ),
          );
          _cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo recordatorio'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D7F3C)),
            )
          : RefreshIndicator(
              color: const Color(0xFF1D7F3C),
              onRefresh: _cargar,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _listaRecordatorios(_pendientes, true),
                  _listaRecordatorios(_completados, false),
                ],
              ),
            ),
    );
  }
}
