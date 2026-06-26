import 'package:flutter/material.dart';
import 'package:crops4you/models/cultivo.dart';
import 'package:crops4you/services/cultivo_service.dart';

class CultivosFormScreen extends StatefulWidget {
  final int parcelaId;
  final Cultivo? cultivo;
  const CultivosFormScreen({super.key, required this.parcelaId, this.cultivo});

  @override
  State<CultivosFormScreen> createState() => _CultivosFormScreenState();
}

class _CultivosFormScreenState extends State<CultivosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _service = CultivoService();
  String _estado = 'activo';
  DateTime _fechaSiembra = DateTime.now();
  bool _loading = false;

  bool get _esEdicion => widget.cultivo != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.cultivo!.nombre;
      _notasCtrl.text = widget.cultivo!.notas ?? '';
      _estado = widget.cultivo!.estado;
      _fechaSiembra =
          DateTime.tryParse(widget.cultivo!.fechaSiembra) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSiembra,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaSiembra = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cultivo = Cultivo(
        parcelaId: widget.parcelaId,
        nombre: _nombreCtrl.text.trim(),
        fechaSiembra:
            '${_fechaSiembra.year}-${_fechaSiembra.month.toString().padLeft(2, '0')}-${_fechaSiembra.day.toString().padLeft(2, '0')}',
        estado: _estado,
        notas: _notasCtrl.text.trim(),
      );
      if (_esEdicion) {
        await _service.update(widget.cultivo!.id!, cultivo);
      } else {
        await _service.create(cultivo);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Cultivo actualizado correctamente'
                  : 'Cultivo creado correctamente',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Cultivo' : 'Nuevo Cultivo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del cultivo',
                  prefixIcon: const Icon(Icons.eco, color: Color(0xFF1D7F3C)),
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
                            'Fecha de siembra',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1D7F3C),
                            ),
                          ),
                          Text(
                            '${_fechaSiembra.day}/${_fechaSiembra.month}/${_fechaSiembra.year}',
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
              const Text(
                'Estado del cultivo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'activo',
                    label: Text('Activo'),
                    icon: Icon(Icons.eco, size: 16),
                  ),
                  ButtonSegment(
                    value: 'cosechado',
                    label: Text('Cosechado'),
                    icon: Icon(Icons.agriculture, size: 16),
                  ),
                  ButtonSegment(
                    value: 'perdido',
                    label: Text('Perdido'),
                    icon: Icon(Icons.warning_amber, size: 16),
                  ),
                ],
                selected: {_estado},
                onSelectionChanged: (s) => setState(() => _estado = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notasCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
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
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    _esEdicion ? 'Actualizar cultivo' : 'Guardar cultivo',
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
