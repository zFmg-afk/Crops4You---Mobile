import 'package:crops4you/main.dart';
import 'package:crops4you/models/cultivo.dart';

class CultivoService {
  final _table = 'cultivos';

  Future<List<Cultivo>> getAll() async {
    final data = await supabase
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Cultivo.fromJson(e)).toList();
  }

  Future<List<Cultivo>> getAllConParcela() async {
    final data = await supabase
        .from(_table)
        .select('*, parcelas(nombre)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Cultivo.fromJson(e)).toList();
  }

  Future<List<Cultivo>> getByParcela(int parcelaId) async {
    final data = await supabase
        .from(_table)
        .select()
        .eq('parcela_id', parcelaId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Cultivo.fromJson(e)).toList();
  }

  Future<void> create(Cultivo cultivo) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = cultivo.toJson();
    data['user_id'] = user.id;
    await supabase.from(_table).insert(data);
  }

  Future<void> update(int id, Cultivo cultivo) async {
    await supabase.from(_table).update(cultivo.toJson()).eq('id', id);
  }

  Future<void> delete(int id) async {
    await supabase.from(_table).delete().eq('id', id);
  }
}
