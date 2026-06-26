import 'package:crops4you/main.dart';
import 'package:crops4you/models/parcela.dart';

class ParcelaService {
  final _table = 'parcelas';

  Future<List<Parcela>> getAll() async {
    final data = await supabase
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Parcela.fromJson(e)).toList();
  }

  Future<void> create(Parcela parcela) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = parcela.toJson();
    data['user_id'] = user.id;
    await supabase.from(_table).insert(data);
  }

  Future<void> update(int id, Parcela parcela) async {
    await supabase.from(_table).update(parcela.toJson()).eq('id', id);
  }

  Future<void> delete(int id) async {
    await supabase.from(_table).delete().eq('id', id);
  }
}
