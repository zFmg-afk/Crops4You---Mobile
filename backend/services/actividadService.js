const supabase = require('../config/db');

exports.getAll = async (userId) => {
  const { data, error } = await supabase
    .from('actividades')
    .select('*')
    .eq('user_id', userId)
    .order('fecha', { ascending: false });
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.getById = async (id, userId) => {
  const { data, error } = await supabase
    .from('actividades')
    .select('*')
    .eq('id', id)
    .eq('user_id', userId)
    .maybeSingle();
  if (!data) throw { status: 404, message: 'Actividad no encontrada' };
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.create = async (body) => {
  if (!body.cultivo_id || !body.tipo || !body.fecha) {
    throw { status: 400, message: 'Faltan campos requeridos: cultivo_id, tipo, fecha' };
  }

  const { data: cultivo, error: cultivoError } = await supabase
    .from('cultivos')
    .select('id')
    .eq('id', body.cultivo_id)
    .maybeSingle();
  if (cultivoError) throw { status: 500, message: cultivoError.message };
  if (!cultivo) throw { status: 404, message: 'El cultivo asociado no existe' };

  const { data, error } = await supabase
    .from('actividades')
    .insert({
      cultivo_id: body.cultivo_id,
      tipo: body.tipo,
      fecha: body.fecha,
      descripcion: body.descripcion || null,
      completado: body.completado ?? false,
      user_id: body.user_id,
    })
    .select()
    .single();
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.update = async (id, body) => {
  const updateData = {};
  if (body.cultivo_id !== undefined) {
    const { data: cultivo, error: cultivoError } = await supabase
      .from('cultivos')
      .select('id')
      .eq('id', body.cultivo_id)
      .maybeSingle();
    if (cultivoError) throw { status: 500, message: cultivoError.message };
    if (!cultivo) throw { status: 404, message: 'El cultivo asociado no existe' };
    updateData.cultivo_id = body.cultivo_id;
  }
  if (body.tipo !== undefined) updateData.tipo = body.tipo;
  if (body.fecha !== undefined) updateData.fecha = body.fecha;
  if (body.descripcion !== undefined) updateData.descripcion = body.descripcion;
  if (body.completado !== undefined) updateData.completado = body.completado;

  const { data, error } = await supabase
    .from('actividades')
    .update(updateData)
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Actividad no encontrada' };
  return data[0];
};

exports.remove = async (id) => {
  const { data, error } = await supabase
    .from('actividades')
    .delete()
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Actividad no encontrada' };
  return { mensaje: 'Actividad eliminada correctamente' };
};
