import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapaParcelaScreen extends StatefulWidget {
  const MapaParcelaScreen({super.key});

  @override
  State<MapaParcelaScreen> createState() => _MapaParcelaScreenState();
}

class _MapaParcelaScreenState extends State<MapaParcelaScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _puntos = [];
  LatLng _centroInicial = const LatLng(20.1167, -101.1833);
  bool _cargandoUbicacion = true;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _centroInicial = LatLng(pos.latitude, pos.longitude);
        _cargandoUbicacion = false;
      });
      _mapController.move(_centroInicial, 17);
    } catch (e) {
      setState(() => _cargandoUbicacion = false);
    }
  }

  void _agregarPunto(TapPosition tapPosition, LatLng punto) {
    setState(() => _puntos.add(punto));
  }

  void _quitarUltimoPunto() {
    if (_puntos.isEmpty) return;
    setState(() => _puntos.removeLast());
  }

  void _limpiar() {
    setState(() => _puntos.clear());
  }

  void _confirmar() {
    if (_puntos.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas al menos 3 puntos para definir el área'),
        ),
      );
      return;
    }

    final lat =
        _puntos.map((p) => p.latitude).reduce((a, b) => a + b) / _puntos.length;
    final lng =
        _puntos.map((p) => p.longitude).reduce((a, b) => a + b) /
        _puntos.length;

    Navigator.pop(context, {
      'centro': {'lat': lat, 'lng': lng},
      'puntos': _puntos
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delimitar parcela'),
        actions: [
          if (_puntos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Quitar último punto',
              onPressed: _quitarUltimoPunto,
            ),
          if (_puntos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Limpiar todo',
              onPressed: _limpiar,
            ),
        ],
      ),
      body: _cargandoUbicacion
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1D7F3C)),
                  SizedBox(height: 16),
                  Text(
                    'Obteniendo tu ubicación...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _centroInicial,
                    initialZoom: 17,
                    onTap: _agregarPunto,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.crops4you.app',
                    ),
                    if (_puntos.length >= 3)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _puntos,
                            color: const Color(0xFF1D7F3C).withOpacity(0.3),
                            borderColor: const Color(0xFF1D7F3C),
                            borderStrokeWidth: 2.5,
                          ),
                        ],
                      ),
                    if (_puntos.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _puntos,
                            color: const Color(0xFF1D7F3C),
                            strokeWidth: 2,
                            isDotted: true,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _puntos.asMap().entries.map((e) {
                        return Marker(
                          point: e.value,
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1D7F3C),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Instrucciones
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _puntos.isEmpty
                                ? 'Toca el mapa para colocar puntos y delimitar tu parcela'
                                : _puntos.length < 3
                                ? 'Agrega ${3 - _puntos.length} punto(s) más para formar el área'
                                : 'Área definida con ${_puntos.length} puntos. Confirma o agrega más.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contador
                if (_puntos.isNotEmpty)
                  Positioned(
                    top: 70,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7F3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_puntos.length} punto(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                // Botón confirmar
                if (_puntos.length >= 3)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Confirmar área de parcela',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1D7F3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _confirmar,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
