import 'package:crops4you/main.dart';
import 'package:crops4you/models/insumo.dart';

class InsumoService {
  final _table = 'insumos';

  Future<List<Insumo>> getByCultivo(int cultivoId) async {
    final data = await supabase
        .from(_table)
        .select()
        .eq('cultivo_id', cultivoId)
        .order('fecha', ascending: false);
    return (data as List).map((e) => Insumo.fromJson(e)).toList();
  }

  Future<void> create(Insumo insumo) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = insumo.toJson();
    data['user_id'] = user.id;
    await supabase.from(_table).insert(data);
  }

  Future<void> delete(int id) async {
    await supabase.from(_table).delete().eq('id', id);
  }
}
