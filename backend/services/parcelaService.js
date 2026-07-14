const supabase = require('../config/db');

const authHeaders = (token) => (token ? { Authorization: `Bearer ${token}` } : {});

exports.getAll = async (userId, token) => {
  const { data, error } = await supabase
    .from('parcelas')
    .select('*', { headers: authHeaders(token) })
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.getById = async (id, userId, token) => {
  const { data, error } = await supabase
    .from('parcelas')
    .select('*', { headers: authHeaders(token) })
    .eq('id', id)
    .eq('user_id', userId)
    .maybeSingle();
  if (!data) throw { status: 404, message: 'Parcela no encontrada' };
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.create = async (body, token) => {
  if (!body.nombre || !body.user_id) {
    throw { status: 400, message: 'Faltan campos requeridos: nombre, user_id' };
  }
  const { data, error } = await supabase
    .from('parcelas')
    .insert(
      {
        nombre: body.nombre,
        descripcion: body.descripcion || null,
        latitud: body.latitud || null,
        longitud: body.longitud || null,
        poligono: body.poligono || null,
        user_id: body.user_id,
      },
      { headers: authHeaders(token) },
    )
    .select()
    .single();
  if (error) throw { status: 500, message: error.message };
  return data;
};

exports.update = async (id, body, token) => {
  const updateData = {};
  if (body.nombre !== undefined) updateData.nombre = body.nombre;
  if (body.descripcion !== undefined) updateData.descripcion = body.descripcion;
  if (body.latitud !== undefined) updateData.latitud = body.latitud;
  if (body.longitud !== undefined) updateData.longitud = body.longitud;
  if (body.poligono !== undefined) updateData.poligono = body.poligono;

  const { data, error } = await supabase
    .from('parcelas')
    .update(updateData, { headers: authHeaders(token) })
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Parcela no encontrada' };
  return data[0];
};

exports.remove = async (id, token) => {
  const { data, error } = await supabase
    .from('parcelas')
    .delete({ headers: authHeaders(token) })
    .eq('id', id)
    .select();
  if (error) throw { status: 500, message: error.message };
  if (!data || data.length === 0) throw { status: 404, message: 'Parcela no encontrada' };
  return { mensaje: 'Parcela eliminada correctamente' };
};
