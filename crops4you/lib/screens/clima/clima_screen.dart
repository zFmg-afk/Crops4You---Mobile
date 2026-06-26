import 'package:flutter/material.dart';
import 'package:crops4you/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  final _service = WeatherService();
  Map<String, dynamic>? _clima;
  List<Map<String, dynamic>> _pronostico = [];
  bool _loading = true;
  String? _error;
  Position? _posicion;

  @override
  void initState() {
    super.initState();
    _cargarClima();
  }

  Future<void> _cargarClima() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final posicion = await _service.obtenerUbicacion();
      final clima = await _service.getClimaActual(
        posicion.latitude,
        posicion.longitude,
      );
      final pronostico = await _service.getPronostico(
        posicion.latitude,
        posicion.longitude,
      );

      // Procesar pronóstico — un dato por día
      final List<Map<String, dynamic>> diasUnicos = [];
      final Set<String> diasVistos = {};

      for (final item in pronostico['list'] as List) {
        final fecha = item['dt_txt'].toString().split(' ')[0];
        if (!diasVistos.contains(fecha) && diasUnicos.length < 5) {
          diasVistos.add(fecha);
          diasUnicos.add(item);
        }
      }

      setState(() {
        _posicion = posicion;
        _clima = clima;
        _pronostico = diasUnicos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  IconData _iconoClima(String descripcion) {
    final d = descripcion.toLowerCase();
    if (d.contains('lluvia') || d.contains('rain')) return Icons.umbrella;
    if (d.contains('nube') || d.contains('cloud')) return Icons.cloud;
    if (d.contains('tormenta') || d.contains('storm'))
      return Icons.thunderstorm;
    if (d.contains('nieve') || d.contains('snow')) return Icons.ac_unit;
    if (d.contains('niebla') || d.contains('mist')) return Icons.foggy;
    return Icons.wb_sunny;
  }

  String _nombreDia(String fechaStr) {
    final fecha = DateTime.parse(fechaStr);
    const dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return dias[fecha.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarClima),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1D7F3C)),
                  SizedBox(height: 16),
                  Text(
                    'Obteniendo tu ubicación y clima...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: _cargarClima,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF1D7F3C),
              onRefresh: _cargarClima,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Tarjeta principal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D7F3C), Color(0xFF145C2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _clima!['name'] ?? 'Tu ubicación',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            _iconoClima(_clima!['weather'][0]['description']),
                            size: 64,
                            color: const Color(0xFFFFB81C),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_clima!['main']['temp'].round()}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _clima!['weather'][0]['description']
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _datoClima(
                                Icons.thermostat,
                                'Sensación',
                                '${_clima!['main']['feels_like'].round()}°C',
                              ),
                              _datoClima(
                                Icons.water_drop,
                                'Humedad',
                                '${_clima!['main']['humidity']}%',
                              ),
                              _datoClima(
                                Icons.air,
                                'Viento',
                                '${(_clima!['wind']['speed'] * 3.6).round()} km/h',
                              ),
                              _datoClima(
                                Icons.compress,
                                'Presión',
                                '${_clima!['main']['pressure']} hPa',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coordenadas
                    if (_posicion != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF1D7F3C),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lat: ${_posicion!.latitude.toStringAsFixed(4)}, Lng: ${_posicion!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Pronóstico 5 días
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pronóstico 5 días',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _pronostico.map((d) {
                              final fecha = d['dt_txt'].toString().split(
                                ' ',
                              )[0];
                              final desc = d['weather'][0]['description'];
                              final temp = d['main']['temp'].round();
                              final min = d['main']['temp_min'].round();
                              return Column(
                                children: [
                                  Text(
                                    _nombreDia(fecha),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Icon(
                                    _iconoClima(desc),
                                    color: const Color(0xFF1D7F3C),
                                    size: 26,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$temp°',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$min°',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recomendación agrícola
                    _recomendacionAgricola(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _recomendacionAgricola() {
    if (_clima == null) return const SizedBox();

    final temp = _clima!['main']['temp'] as num;
    final humedad = _clima!['main']['humidity'] as num;
    final descripcion = _clima!['weather'][0]['description']
        .toString()
        .toLowerCase();

    String mensaje;
    IconData icono;
    Color color;

    if (descripcion.contains('lluvia') || descripcion.contains('rain')) {
      mensaje =
          'Se esperan lluvias. Evita aplicar fertilizantes o pesticidas hoy ya que la lluvia los diluirá.';
      icono = Icons.umbrella;
      color = const Color(0xFF1976D2);
    } else if (temp > 35) {
      mensaje =
          'Temperatura muy alta. Riega en la mañana temprano o al atardecer para evitar la evaporación excesiva.';
      icono = Icons.wb_sunny;
      color = Colors.orange;
    } else if (humedad < 30) {
      mensaje =
          'Humedad baja. Considera aumentar la frecuencia de riego para mantener la humedad del suelo.';
      icono = Icons.water_drop;
      color = const Color(0xFFFFB81C);
    } else if (temp < 10) {
      mensaje =
          'Temperatura baja. Protege los cultivos sensibles a las heladas con cubiertas o invernaderos.';
      icono = Icons.ac_unit;
      color = const Color(0xFF1976D2);
    } else {
      mensaje =
          'Condiciones favorables para actividades agrícolas como siembra, fertilización o fumigación.';
      icono = Icons.check_circle_outline;
      color = const Color(0xFF1D7F3C);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación agrícola',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoClima(IconData icon, String label, String valor) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}
