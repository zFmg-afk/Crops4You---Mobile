import 'package:crops4you/main.dart';
import 'package:crops4you/models/recordatorio.dart';

class RecordatorioService {
  final _table = 'recordatorios';
  static const _select = '*, cultivos(nombre, parcelas(nombre))';

  Future<List<Recordatorio>> getAll() async {
    final data = await supabase
        .from(_table)
        .select(_select)
        .order('fecha_recordatorio');
    return (data as List).map((e) => Recordatorio.fromJson(e)).toList();
  }

  Future<List<Recordatorio>> getPendientes() async {
    final data = await supabase
        .from(_table)
        .select(_select)
        .eq('completado', false)
        .order('fecha_recordatorio');
    return (data as List).map((e) => Recordatorio.fromJson(e)).toList();
  }

  Future<List<Recordatorio>> getByCultivo(int cultivoId) async {
    final data = await supabase
        .from(_table)
        .select(_select)
        .eq('cultivo_id', cultivoId)
        .order('fecha_recordatorio');
    return (data as List).map((e) => Recordatorio.fromJson(e)).toList();
  }

  Future<void> create(Recordatorio r) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = r.toJson();
    data['user_id'] = user.id;
    await supabase.from(_table).insert(data);
  }

  Future<void> update(int id, Recordatorio r) async {
    await supabase.from(_table).update(r.toUpdateJson()).eq('id', id);
  }

  Future<void> completar(int id) async {
    await supabase.from(_table).update({'completado': true}).eq('id', id);
  }

  Future<void> delete(int id) async {
    await supabase.from(_table).delete().eq('id', id);
  }
}
