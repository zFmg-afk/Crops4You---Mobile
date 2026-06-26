import 'package:flutter/material.dart';
import 'package:crops4you/models/recordatorio.dart';
import 'package:crops4you/services/recordatorio_service.dart';
import 'package:crops4you/services/cultivo_service.dart';
import 'package:crops4you/models/cultivo.dart';

class RecordatorioFormScreen extends StatefulWidget {
  final int? cultivoId;
  final Recordatorio? recordatorio;

  const RecordatorioFormScreen({super.key, this.cultivoId, this.recordatorio});

  @override
  State<RecordatorioFormScreen> createState() => _RecordatorioFormScreenState();
}

class _RecordatorioFormScreenState extends State<RecordatorioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _service = RecordatorioService();
  final _cultivoService = CultivoService();

  List<Cultivo> _cultivos = [];
  int? _cultivoSeleccionado;
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 8, minute: 0);
  bool _loading = false;
  bool _loadingCultivos = true;

  bool get _esEdicion => widget.recordatorio != null;

  @override
  void initState() {
    super.initState();
    _cultivoSeleccionado = widget.cultivoId ?? widget.recordatorio?.cultivoId;

    if (_esEdicion) {
      _tituloCtrl.text = widget.recordatorio!.titulo;
      _fecha = widget.recordatorio!.fechaRecordatorio;
      _hora = TimeOfDay.fromDateTime(widget.recordatorio!.fechaRecordatorio);
    }

    _cargarCultivos();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCultivos() async {
    try {
      final data = await _cultivoService.getAllConParcela();
      setState(() {
        _cultivos = data;
        _loadingCultivos = false;
      });
    } catch (e) {
      setState(() => _loadingCultivos = false);
    }
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cultivoSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un cultivo')));
      return;
    }

    setState(() => _loading = true);
    try {
      final fechaCompleta = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        _hora.hour,
        _hora.minute,
      );

      final recordatorio = Recordatorio(
        id: widget.recordatorio?.id,
        cultivoId: _cultivoSeleccionado!,
        titulo: _tituloCtrl.text.trim(),
        fechaRecordatorio: fechaCompleta,
      );

      if (_esEdicion) {
        await _service.update(widget.recordatorio!.id!, recordatorio);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio actualizado correctamente'),
              backgroundColor: Color(0xFF1D7F3C),
            ),
          );
        }
      } else {
        await _service.create(recordatorio);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio creado correctamente'),
              backgroundColor: Color(0xFF1D7F3C),
            ),
          );
        }
      }
      Navigator.pop(context);
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
        title: Text(_esEdicion ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
      ),
      body: _loadingCultivos
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D7F3C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: InputDecoration(
                        labelText: 'Título del recordatorio',
                        prefixIcon: const Icon(
                          Icons.alarm,
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
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
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

                    const Text(
                      'Cultivo asociado',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _cultivoSeleccionado,
                          isExpanded: true,
                          hint: const Text('Selecciona un cultivo'),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _cultivos.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    c.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (c.nombreParcela != null)
                                    Text(
                                      c.nombreParcela!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _cultivoSeleccionado = v),
                        ),
                      ),
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
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _pickHora,
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
                              Icons.access_time,
                              color: Color(0xFF1D7F3C),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1D7F3C),
                                  ),
                                ),
                                Text(
                                  '${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        icon: Icon(_esEdicion ? Icons.save : Icons.add),
                        label: Text(
                          _esEdicion
                              ? 'Actualizar recordatorio'
                              : 'Guardar recordatorio',
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
