import 'package:flutter/material.dart';
import 'package:crops4you/models/parcela.dart';
import 'package:crops4you/models/cultivo.dart';
import 'package:crops4you/services/cultivo_service.dart';
import 'package:crops4you/screens/cultivos/cultivos_form_screen.dart';
import 'package:crops4you/screens/cultivos/cultivo_detalle_screen.dart';

class CultivosScreen extends StatefulWidget {
  final Parcela parcela;
  const CultivosScreen({super.key, required this.parcela});

  @override
  State<CultivosScreen> createState() => _CultivosScreenState();
}

class _CultivosScreenState extends State<CultivosScreen> {
  final _service = CultivoService();
  List<Cultivo> _cultivos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getByParcela(widget.parcela.id!);
      setState(() {
        _cultivos = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar cultivos: $e')));
      }
    }
  }

  Future<void> _eliminar(Cultivo c) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cultivo'),
        content: Text('¿Eliminar "${c.nombre}"?'),
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
    if (confirmar == true && c.id != null) {
      await _service.delete(c.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cultivo eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activos = _cultivos.where((c) => c.estado == 'activo').toList();
    final cosechados = _cultivos.where((c) => c.estado == 'cosechado').toList();
    final perdidos = _cultivos.where((c) => c.estado == 'perdido').toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.parcela.nombre),
            Text(
              '${_cultivos.length} cultivo(s)',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CultivosFormScreen(parcelaId: widget.parcela.id!),
            ),
          );
          _cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cultivo'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D7F3C)),
            )
          : RefreshIndicator(
              color: const Color(0xFF1D7F3C),
              onRefresh: _cargar,
              child: _cultivos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay cultivos en esta parcela',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toca el botón para agregar uno',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      children: [
                        if (activos.isNotEmpty) ...[
                          _SeccionHeader(
                            titulo: 'Activos',
                            color: const Color(0xFF1D7F3C),
                            cantidad: activos.length,
                          ),
                          ...activos.map(
                            (c) => _CultivoCard(
                              cultivo: c,
                              onTap: () => _navegarDetalle(c),
                              onEditar: () => _editar(c),
                              onEliminar: () => _eliminar(c),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (cosechados.isNotEmpty) ...[
                          _SeccionHeader(
                            titulo: 'Cosechados',
                            color: const Color(0xFF1976D2),
                            cantidad: cosechados.length,
                          ),
                          ...cosechados.map(
                            (c) => _CultivoCard(
                              cultivo: c,
                              onTap: () => _navegarDetalle(c),
                              onEditar: () => _editar(c),
                              onEliminar: () => _eliminar(c),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (perdidos.isNotEmpty) ...[
                          _SeccionHeader(
                            titulo: 'Perdidos',
                            color: Colors.red,
                            cantidad: perdidos.length,
                          ),
                          ...perdidos.map(
                            (c) => _CultivoCard(
                              cultivo: c,
                              onTap: () => _navegarDetalle(c),
                              onEditar: () => _editar(c),
                              onEliminar: () => _eliminar(c),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
    );
  }

  Future<void> _navegarDetalle(Cultivo c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CultivoDetalleScreen(cultivo: c)),
    );
    _cargar();
  }

  Future<void> _editar(Cultivo c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CultivosFormScreen(parcelaId: widget.parcela.id!, cultivo: c),
      ),
    );
    _cargar();
  }
}

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final Color color;
  final int cantidad;

  const _SeccionHeader({
    required this.titulo,
    required this.color,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cantidad',
              style: TextStyle(
                color: color,
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

class _CultivoCard extends StatelessWidget {
  final Cultivo cultivo;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _CultivoCard({
    required this.cultivo,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

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

  IconData get _icon {
    switch (cultivo.estado) {
      case 'activo':
        return Icons.eco;
      case 'cosechado':
        return Icons.agriculture;
      case 'perdido':
        return Icons.warning_amber;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _color.withOpacity(0.12),
                radius: 24,
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cultivo.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Siembra: ${cultivo.fechaSiembra}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (cultivo.notas != null && cultivo.notas!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cultivo.notas!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
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
                onSelected: (v) {
                  if (v == 'editar') {
                    onEditar();
                  } else if (v == 'eliminar') {
                    onEliminar();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
