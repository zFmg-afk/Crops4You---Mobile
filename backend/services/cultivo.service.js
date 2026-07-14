const supabase = require('../config/db');

const authHeaders = (token) => (token ? { Authorization: `Bearer ${token}` } : {});

const getAll = async (userId, parcelaId, token) => {
  let query = supabase
    .from('cultivos')
    .select('*, parcelas(nombre)', { headers: authHeaders(token) })
    .eq('user_id', userId);

  if (parcelaId) {
    query = query.eq('parcela_id', parcelaId);
  }

  const { data, error } = await query.order('created_at', { ascending: false });

  if (error) throw error;
  return data;
};

const getById = async (id, userId, token) => {
  const { data, error } = await supabase
    .from('cultivos')
    .select('*, parcelas(nombre)', { headers: authHeaders(token) })
    .eq('id', id)
    .eq('user_id', userId)
    .single();

  if (error) throw error;
  return data;
};

const create = async (data, userId, token) => {
  const { data: cultivo, error } = await supabase
    .from('cultivos')
    .insert({ ...data, user_id: userId }, { headers: authHeaders(token) })
    .select()
    .single();

  if (error) throw error;
  return cultivo;
};

const update = async (id, data, userId, token) => {
  const { data: cultivo, error } = await supabase
    .from('cultivos')
    .update(data, { headers: authHeaders(token) })
    .eq('id', id)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) throw error;
  return cultivo;
};

const remove = async (id, userId, token) => {
  const { error } = await supabase
    .from('cultivos')
    .delete({ headers: authHeaders(token) })
    .eq('id', id)
    .eq('user_id', userId);

  if (error) throw error;
};

const parcelaExists = async (parcelaId, userId, token) => {
  const { data, error } = await supabase
    .from('parcelas')
    .select('id', { headers: authHeaders(token) })
    .eq('id', parcelaId)
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw error;
  return !!data;
};

module.exports = { getAll, getById, create, update, remove, parcelaExists };
