import 'package:crops4you/main.dart';
import 'package:crops4you/models/actividad.dart';

class ActividadService {
  final _table = 'actividades';

  Future<List<Actividad>> getByCultivo(int cultivoId) async {
    final data = await supabase
        .from(_table)
        .select()
        .eq('cultivo_id', cultivoId)
        .order('fecha', ascending: false);
    return (data as List).map((e) => Actividad.fromJson(e)).toList();
  }

  Future<void> create(Actividad actividad) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = actividad.toJson();
    data['user_id'] = user.id;
    await supabase.from(_table).insert(data);
  }

  Future<void> completar(int id) async {
    await supabase.from(_table).update({'completado': true}).eq('id', id);
  }

  Future<void> desmarcar(int id) async {
    await supabase.from(_table).update({'completado': false}).eq('id', id);
  }

  Future<void> delete(int id) async {
    await supabase.from(_table).delete().eq('id', id);
  }
}
