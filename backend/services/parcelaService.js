const { supabase: defaultSupabase } = require('../config/db');

exports.getAll = async (userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('parcelas')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.getById = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('parcelas')
    .select('*')
    .eq('id', id)
    .eq('user_id', userId)
    .maybeSingle();
  if (!data) throw { status: 404, message: 'Parcela no encontrada' };
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.create = async (body, sb = defaultSupabase) => {
  if (!body.nombre || !body.user_id) {
    throw { status: 400, message: 'Faltan campos requeridos: nombre, user_id' };
  }
  const { data, error } = await sb
    .from('parcelas')
    .insert({
      nombre: body.nombre,
      descripcion: body.descripcion || null,
      latitud: body.latitud || null,
      longitud: body.longitud || null,
      poligono: body.poligono || null,
      user_id: body.user_id,
    })
    .select()
    .single();
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.update = async (id, body, sb = defaultSupabase) => {
  const updateData = {};
  if (body.nombre !== undefined) updateData.nombre = body.nombre;
  if (body.descripcion !== undefined) updateData.descripcion = body.descripcion;
  if (body.latitud !== undefined) updateData.latitud = body.latitud;
  if (body.longitud !== undefined) updateData.longitud = body.longitud;
  if (body.poligono !== undefined) updateData.poligono = body.poligono;

  const { data, error } = await sb
    .from('parcelas')
    .update(updateData)
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Parcela no encontrada' };
  return data[0];
};

exports.remove = async (id, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('parcelas')
    .delete()
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Parcela no encontrada' };
  return { mensaje: 'Parcela eliminada correctamente' };
};
