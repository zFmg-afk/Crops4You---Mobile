import 'package:flutter/material.dart';
import 'package:crops4you/models/actividad.dart';
import 'package:crops4you/services/actividad_service.dart';

class ActividadFormScreen extends StatefulWidget {
  final int cultivoId;
  const ActividadFormScreen({super.key, required this.cultivoId});

  @override
  State<ActividadFormScreen> createState() => _ActividadFormScreenState();
}

class _ActividadFormScreenState extends State<ActividadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _service = ActividadService();
  String _tipo = 'riego';
  DateTime _fecha = DateTime.now();
  bool _completado = false;
  bool _loading = false;

  final List<Map<String, dynamic>> _tipos = [
    {'valor': 'siembra', 'label': 'Siembra', 'icon': Icons.grass},
    {'valor': 'riego', 'label': 'Riego', 'icon': Icons.water_drop},
    {'valor': 'fertilizacion', 'label': 'Fertilización', 'icon': Icons.science},
    {'valor': 'fumigacion', 'label': 'Fumigación', 'icon': Icons.pest_control},
    {'valor': 'cosecha', 'label': 'Cosecha', 'icon': Icons.agriculture},
    {'valor': 'otro', 'label': 'Otro', 'icon': Icons.build},
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final actividad = Actividad(
        cultivoId: widget.cultivoId,
        tipo: _tipo,
        fecha:
            '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
        descripcion: _descCtrl.text.trim(),
        completado: _completado,
      );
      await _service.create(actividad);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad registrada correctamente'),
            backgroundColor: Color(0xFF1D7F3C),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Actividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de actividad',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: _tipos.map((t) {
                  final seleccionado = _tipo == t['valor'];
                  return GestureDetector(
                    onTap: () => setState(() => _tipo = t['valor']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFF1D7F3C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: seleccionado
                              ? const Color(0xFF1D7F3C)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            color: seleccionado
                                ? Colors.white
                                : const Color(0xFF1D7F3C),
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: seleccionado
                                  ? Colors.white
                                  : const Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickFecha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF1D7F3C),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1D7F3C),
                            ),
                          ),
                          Text(
                            '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
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
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'Marcar como completada',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'La actividad ya fue realizada',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                value: _completado,
                onChanged: (v) => setState(() => _completado = v ?? false),
                activeColor: const Color(0xFF1D7F3C),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar actividad',
                    style: TextStyle(fontSize: 16),
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
