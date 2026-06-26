import 'package:flutter/material.dart';
import 'package:crops4you/models/insumo.dart';
import 'package:crops4you/services/insumo_service.dart';

class InsumoFormScreen extends StatefulWidget {
  final int cultivoId;
  const InsumoFormScreen({super.key, required this.cultivoId});

  @override
  State<InsumoFormScreen> createState() => _InsumoFormScreenState();
}

class _InsumoFormScreenState extends State<InsumoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _service = InsumoService();
  String _tipo = 'fertilizante';
  String _unidad = 'kg';
  DateTime _fecha = DateTime.now();
  bool _loading = false;

  final _tipos = ['fertilizante', 'pesticida', 'herbicida', 'semilla', 'otro'];
  final _unidades = ['kg', 'g', 'L', 'mL', 'unidad'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _costoCtrl.dispose();
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
      final insumo = Insumo(
        cultivoId: widget.cultivoId,
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        cantidad: double.parse(_cantidadCtrl.text),
        unidad: _unidad,
        fecha:
            '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
        costo: double.tryParse(_costoCtrl.text),
      );
      await _service.create(insumo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insumo registrado correctamente'),
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

  InputDecoration _deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1D7F3C)),
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
        borderSide: const BorderSide(color: Color(0xFF1D7F3C), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Insumo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: _deco('Nombre del producto', Icons.inventory),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: _deco('Tipo de insumo', Icons.category),
                items: _tipos
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t[0].toUpperCase() + t.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _deco('Cantidad', Icons.numbers),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unidad,
                      decoration: _deco('Unidad', Icons.scale),
                      items: _unidades
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _unidad = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costoCtrl,
                keyboardType: TextInputType.number,
                decoration: _deco('Costo (opcional)', Icons.attach_money),
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
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar insumo',
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
