import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crops4you/services/ai_service.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final _service = AiService();
  final _picker = ImagePicker();
  File? _imagen;
  String? _resultado;
  bool _analizando = false;
  bool _analizado = false;
  ModoAnalisis _modo = ModoAnalisis.cultivo;

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(() {
        _imagen = File(picked.path);
        _resultado = null;
        _analizado = false;
      });
    }
  }

  Future<void> _analizar() async {
    if (_imagen == null) return;
    setState(() {
      _analizando = true;
      _resultado = null;
    });

    try {
      final resultado = await _service.analizarImagenCultivo(
        _imagen!,
        modo: _modo,
      );
      setState(() {
        _resultado = resultado;
        _analizado = true;
        _analizando = false;
      });
    } catch (e) {
      setState(() => _analizando = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _limpiar() {
    setState(() {
      _imagen = null;
      _resultado = null;
      _analizado = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis IA'),
        actions: [
          if (_imagen != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Nueva imagen',
              onPressed: _limpiar,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D7F3C), Color(0xFF145C2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology, color: Color(0xFFFFB81C), size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análisis con Inteligencia Artificial',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Toma o sube una foto y la IA la analizará para detectar posibles problemas.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de modo
            const Text(
              'Modo de análisis',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ModoAnalisis>(
              segments: const [
                ButtonSegment(
                  value: ModoAnalisis.cultivo,
                  label: Text('Cultivo agrícola'),
                  icon: Icon(Icons.grass, size: 16),
                ),
                ButtonSegment(
                  value: ModoAnalisis.planta,
                  label: Text('Identificar planta'),
                  icon: Icon(Icons.local_florist, size: 16),
                ),
              ],
              selected: {_modo},
              onSelectionChanged: (s) {
                setState(() {
                  _modo = s.first;
                  _resultado = null;
                  _analizado = false;
                });
              },
            ),
            const SizedBox(height: 20),

            // Área de imagen
            if (_imagen == null) ...[
              const Text(
                'Selecciona una imagen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BotonFuente(
                      icon: Icons.camera_alt,
                      label: 'Tomar foto',
                      onTap: () => _seleccionarImagen(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotonFuente(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () => _seleccionarImagen(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'La imagen aparecerá aquí',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Imagen seleccionada
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _imagen!,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              if (!_analizado) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Cambiar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF1D7F3C)),
                          foregroundColor: const Color(0xFF1D7F3C),
                        ),
                        onPressed: _analizando
                            ? null
                            : () => _seleccionarImagen(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: _analizando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_analizando ? 'Analizando...' : 'Analizar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _analizando ? null : _analizar,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Cargando
            if (_analizando) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1D7F3C)),
                    SizedBox(height: 16),
                    Text(
                      'La IA está analizando tu imagen...',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Esto puede tardar unos segundos',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],

            // Resultado formateado
            if (_resultado != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Color(0xFF1D7F3C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Resultado del análisis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1D7F3C),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Nueva imagen'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1D7F3C),
                    ),
                    onPressed: _limpiar,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ResultadoFormateado(texto: _resultado!),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _BotonFuente extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BotonFuente({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1D7F3C), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultadoFormateado extends StatelessWidget {
  final String texto;
  const _ResultadoFormateado({required this.texto});

  List<_Seccion> _parsear(String texto) {
    final secciones = <_Seccion>[];
    final lineas = texto.split('\n');
    String tituloActual = '';
    String contenidoActual = '';

    for (final linea in lineas) {
      final limpia = linea.trim();
      if (limpia.isEmpty) continue;

      final esEncabezado = RegExp(r'^\d+\.').hasMatch(limpia);

      if (esEncabezado) {
        if (tituloActual.isNotEmpty) {
          secciones.add(_Seccion(tituloActual, contenidoActual.trim()));
        }
        tituloActual = limpia
            .replaceAll(RegExp(r'^\d+\.\s*\*{0,2}'), '')
            .replaceAll('**', '')
            .trim();
        contenidoActual = '';
      } else {
        contenidoActual +=
            '${limpia.replaceAll('**', '').replaceAll('*', '•')}\n';
      }
    }

    if (tituloActual.isNotEmpty) {
      secciones.add(_Seccion(tituloActual, contenidoActual.trim()));
    }

    if (secciones.isEmpty) {
      secciones.add(
        _Seccion('Análisis', texto.replaceAll('**', '').replaceAll('*', '•')),
      );
    }

    return secciones;
  }

  IconData _iconoSeccion(String titulo, int index) {
    final t = titulo.toLowerCase();
    if (t.contains('estado')) return Icons.monitor_heart;
    if (t.contains('problema') || t.contains('detectado'))
      return Icons.bug_report_outlined;
    if (t.contains('recomend')) return Icons.tips_and_updates_outlined;
    if (t.contains('urgencia')) return Icons.warning_amber_outlined;
    if (t.contains('nombre') || t.contains('identif'))
      return Icons.local_florist_outlined;
    if (t.contains('caracterist')) return Icons.info_outline;
    if (t.contains('cuidado')) return Icons.eco_outlined;
    if (t.contains('dato') || t.contains('uso')) return Icons.lightbulb_outline;
    if (t.contains('interior') || t.contains('exterior'))
      return Icons.home_outlined;
    final iconos = [
      Icons.grass,
      Icons.search,
      Icons.healing,
      Icons.star_outline,
    ];
    return iconos[index % iconos.length];
  }

  Color _colorSeccion(String titulo, int index) {
    final t = titulo.toLowerCase();
    if (t.contains('urgencia')) return Colors.orange;
    if (t.contains('problema') || t.contains('detectado'))
      return Colors.red.shade400;
    if (t.contains('recomend') || t.contains('cuidado'))
      return const Color(0xFF1976D2);
    const colores = [
      Color(0xFF1D7F3C),
      Color(0xFF1976D2),
      Color(0xFFFFB81C),
      Color(0xFF7B1FA2),
    ];
    return colores[index % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    final secciones = _parsear(texto);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: secciones.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final color = _colorSeccion(s.titulo, i);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_iconoSeccion(s.titulo, i), color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  s.contenido,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Seccion {
  final String titulo;
  final String contenido;
  const _Seccion(this.titulo, this.contenido);
}
