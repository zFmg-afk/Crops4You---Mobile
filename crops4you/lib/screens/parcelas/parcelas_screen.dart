import 'package:flutter/material.dart';
import 'package:crops4you/models/parcela.dart';
import 'package:crops4you/services/parcela_service.dart';
import 'package:crops4you/screens/parcelas/parcelas_form_screen.dart';
import 'package:crops4you/screens/cultivos/cultivos_screen.dart';

class ParcelasScreen extends StatefulWidget {
  const ParcelasScreen({super.key});

  @override
  State<ParcelasScreen> createState() => _ParcelasScreenState();
}

class _ParcelasScreenState extends State<ParcelasScreen> {
  final _service = ParcelaService();
  List<Parcela> _parcelas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getAll();
      setState(() {
        _parcelas = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar parcelas: $e')));
      }
    }
  }

  Future<void> _eliminar(Parcela p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar parcela'),
        content: Text(
          '¿Eliminar "${p.nombre}"? También se eliminarán sus cultivos.',
        ),
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
    if (confirmar == true && p.id != null) {
      await _service.delete(p.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parcela eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Parcelas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_parcelas.length} parcela(s)',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ParcelasFormScreen()),
          );
          _cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva parcela'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D7F3C)),
            )
          : RefreshIndicator(
              color: const Color(0xFF1D7F3C),
              onRefresh: _cargar,
              child: _parcelas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.terrain,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes parcelas aún',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toca el botón para agregar tu primera parcela',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _parcelas.length,
                      itemBuilder: (context, i) {
                        final p = _parcelas[i];
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
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1D7F3C),
                              radius: 24,
                              child: Text(
                                p.nombre.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              p.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.descripcion != null &&
                                    p.descripcion!.isNotEmpty)
                                  Text(p.descripcion!),
                                if (p.latitud != null && p.longitud != null)
                                  Text(
                                    'Lat: ${p.latitud!.toStringAsFixed(4)}, Lng: ${p.longitud!.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
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
                                          ParcelasFormScreen(parcela: p),
                                    ),
                                  );
                                  _cargar();
                                } else if (v == 'eliminar') {
                                  _eliminar(p);
                                }
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CultivosScreen(parcela: p),
                                ),
                              );
                              _cargar();
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
