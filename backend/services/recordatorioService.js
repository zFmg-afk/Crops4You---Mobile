const { supabase: defaultSupabase } = require('../config/db');

exports.getAll = async (userId, cultivoId, sb = defaultSupabase) => {
  let query = sb
    .from('recordatorios')
    .select('*, cultivos(nombre, parcelas(nombre))')
    .eq('user_id', userId);
  if (cultivoId) query = query.eq('cultivo_id', cultivoId);
  query = query.order('fecha_recordatorio', { ascending: true });
  const { data, error } = await query;
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.getById = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('recordatorios')
    .select('*, cultivos(nombre, parcelas(nombre))')
    .eq('id', id)
    .eq('user_id', userId)
    .maybeSingle();
  if (error) throw { status: 500, message: error.message };
  if (!data) throw { status: 404, message: 'Recordatorio no encontrado' };
  return data;
};

exports.create = async (body, userId, sb = defaultSupabase) => {
  if (!body.cultivo_id || !body.titulo || !body.fecha_recordatorio) {
    throw {
      status: 400,
      message: 'Faltan campos requeridos: cultivo_id, titulo, fecha_recordatorio',
    };
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
    .from('recordatorios')
    .insert({
      cultivo_id: body.cultivo_id,
      titulo: body.titulo,
      fecha_recordatorio: body.fecha_recordatorio,
      completado: body.completado ?? false,
      user_id: userId,
    })
    .select()
    .single();
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.update = async (id, body, userId, sb = defaultSupabase) => {
  if (Object.keys(body).length === 0) {
    throw { status: 400, message: 'No se enviaron campos para actualizar' };
  }

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
  if (body.titulo !== undefined) updateData.titulo = body.titulo;
  if (body.fecha_recordatorio !== undefined) updateData.fecha_recordatorio = body.fecha_recordatorio;
  if (body.completado !== undefined) updateData.completado = body.completado;

  const { data, error } = await sb
    .from('recordatorios')
    .update(updateData)
    .eq('id', id)
    .eq('user_id', userId)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Recordatorio no encontrado' };
  return data[0];
};

exports.remove = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('recordatorios')
    .delete()
    .eq('id', id)
    .eq('user_id', userId)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Recordatorio no encontrado' };
  return { mensaje: 'Recordatorio eliminado correctamente' };
};