import 'package:flutter/material.dart';
import 'package:crops4you/models/parcela.dart';
import 'package:crops4you/services/parcela_service.dart';
import 'package:crops4you/screens/parcelas/mapa_parcela_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ParcelasFormScreen extends StatefulWidget {
  final Parcela? parcela;
  const ParcelasFormScreen({super.key, this.parcela});

  @override
  State<ParcelasFormScreen> createState() => _ParcelasFormScreenState();
}

class _ParcelasFormScreenState extends State<ParcelasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _service = ParcelaService();
  bool _loading = false;

  double? _latitud;
  double? _longitud;
  List<Map<String, double>>? _poligono;
  int _totalPuntos = 0;

  bool get _esEdicion => widget.parcela != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.parcela!.nombre;
      _descCtrl.text = widget.parcela!.descripcion ?? '';
      _latitud = widget.parcela!.latitud;
      _longitud = widget.parcela!.longitud;
      _poligono = widget.parcela!.poligono;
      _totalPuntos = _poligono?.length ?? 0;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirMapa() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapaParcelaScreen()),
    );

    if (resultado != null) {
      final centro = resultado['centro'] as Map<String, dynamic>;
      final puntos = resultado['puntos'] as List;

      setState(() {
        _latitud = centro['lat'];
        _longitud = centro['lng'];
        _poligono = puntos
            .map(
              (p) => {
                'lat': (p['lat'] as num).toDouble(),
                'lng': (p['lng'] as num).toDouble(),
              },
            )
            .toList();
        _totalPuntos = _poligono!.length;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitud == null || _poligono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes delimitar el área de la parcela en el mapa'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final parcela = Parcela(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        latitud: _latitud,
        longitud: _longitud,
        poligono: _poligono,
      );

      if (_esEdicion) {
        await _service.update(widget.parcela!.id!, parcela);
      } else {
        await _service.create(parcela);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Parcela actualizada correctamente'
                  : 'Parcela creada correctamente',
            ),
            backgroundColor: const Color(0xFF1D7F3C),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // Widget del mini mapa
  Widget _miniMapa() {
    if (_poligono == null || _poligono!.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text(
              'Sin área definida',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final puntos = _poligono!.map((p) => LatLng(p['lat']!, p['lng']!)).toList();

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_latitud!, _longitud!),
            initialZoom: 17,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Desactiva interacción
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.crops4you.app',
            ),
            PolygonLayer(
              polygons: [
                Polygon(
                  points: puntos,
                  color: const Color(0xFF1D7F3C).withOpacity(0.3),
                  borderColor: const Color(0xFF1D7F3C),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_latitud!, _longitud!),
                  width: 30,
                  height: 30,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Parcela' : 'Nueva Parcela'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre de la parcela',
                  prefixIcon: const Icon(
                    Icons.terrain,
                    color: Color(0xFF1D7F3C),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1D7F3C),
                      width: 2,
                    ),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: const Icon(Icons.notes, color: Color(0xFF1D7F3C)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1D7F3C),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Área de la parcela
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Área de la parcela',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (_poligono != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7F3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_totalPuntos puntos',
                        style: const TextStyle(
                          color: Color(0xFF1D7F3C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // MINI MAPA CON EL POLÍGONO
              _miniMapa(),
              const SizedBox(height: 12),

              // Botones de acción del mapa
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        _poligono != null ? Icons.edit : Icons.map,
                        size: 18,
                      ),
                      label: Text(
                        _poligono != null ? 'Editar área' : 'Delimitar área',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1D7F3C),
                        side: const BorderSide(color: Color(0xFF1D7F3C)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _abrirMapa,
                    ),
                  ),
                  if (_poligono != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Limpiar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _latitud = null;
                          _longitud = null;
                          _poligono = null;
                          _totalPuntos = 0;
                        });
                      },
                    ),
                  ],
                ],
              ),

              // Coordenadas del centro
              if (_latitud != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Centro: ${_latitud!.toStringAsFixed(5)}, ${_longitud!.toStringAsFixed(5)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    _esEdicion ? 'Actualizar parcela' : 'Guardar parcela',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _loading ? null : _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
