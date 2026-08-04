const { supabase: defaultSupabase } = require('../config/db');

exports.getAll = async (userId, cultivoId, sb = defaultSupabase) => {
  let query = sb.from('actividades').select('*').eq('user_id', userId);
  if (cultivoId) query = query.eq('cultivo_id', cultivoId);
  query = query.order('fecha', { ascending: false });
  const { data, error } = await query;
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.getById = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('actividades')
    .select('*')
    .eq('id', id)
    .eq('user_id', userId)
    .maybeSingle();
  if (!data) throw { status: 404, message: 'Actividad no encontrada' };
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.create = async (body, userId, sb = defaultSupabase) => {
  if (!body.cultivo_id || !body.tipo || !body.fecha) {
    throw { status: 400, message: 'Faltan campos requeridos: cultivo_id, tipo, fecha' };
  }

  const { data: cultivo, error: cultivoError } = await sb
    .from('cultivos')
    .select('id')
    .eq('id', body.cultivo_id)
    .eq('user_id', userId)
    .maybeSingle();
  if (cultivoError) throw { status: 500, message: cultivoError.message };
  if (!cultivo) throw { status: 404, message: 'El cultivo asociado no existe' };

  const { data, error } = await sb
    .from('actividades')
    .insert({
      cultivo_id: body.cultivo_id,
      tipo: body.tipo,
      fecha: body.fecha,
      descripcion: body.descripcion || null,
      completado: body.completado ?? false,
      user_id: userId,
    })
    .select()
    .single();
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.update = async (id, body, userId, sb = defaultSupabase) => {
  const updateData = {};
  if (body.cultivo_id !== undefined) {
    const { data: cultivo, error: cultivoError } = await sb
      .from('cultivos')
      .select('id')
      .eq('id', body.cultivo_id)
      .eq('user_id', userId)
      .maybeSingle();
    if (cultivoError) throw { status: 500, message: cultivoError.message };
    if (!cultivo) throw { status: 404, message: 'El cultivo asociado no existe' };
    updateData.cultivo_id = body.cultivo_id;
  }
  if (body.tipo !== undefined) updateData.tipo = body.tipo;
  if (body.fecha !== undefined) updateData.fecha = body.fecha;
  if (body.descripcion !== undefined) updateData.descripcion = body.descripcion;
  if (body.completado !== undefined) updateData.completado = body.completado;

  const { data, error } = await sb
    .from('actividades')
    .update(updateData)
    .eq('id', id)
    .eq('user_id', userId)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Actividad no encontrada' };
  return data[0];
};

exports.remove = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('actividades')
    .delete()
    .eq('id', id)
    .eq('user_id', userId)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Actividad no encontrada' };
  return { mensaje: 'Actividad eliminada correctamente' };
};
