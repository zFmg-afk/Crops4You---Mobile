const { supabase: defaultSupabase } = require('../config/db');

const getAll = async (userId, parcelaId, sb = defaultSupabase) => {
  let query = sb
    .from('cultivos')
    .select('*, parcelas(nombre)')
    .eq('user_id', userId);

  if (parcelaId) {
    query = query.eq('parcela_id', parcelaId);
  }

  const { data, error } = await query.order('created_at', { ascending: false });

  if (error) throw error;
  return data;
};

const getById = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('cultivos')
    .select('*, parcelas(nombre)')
    .eq('id', id)
    .eq('user_id', userId)
    .single();

  if (error) throw error;
  return data;
};

const create = async (data, userId, sb = defaultSupabase) => {
  const { data: cultivo, error } = await sb
    .from('cultivos')
    .insert({ ...data, user_id: userId })
    .select()
    .single();

  if (error) throw error;
  return cultivo;
};

const update = async (id, data, userId, sb = defaultSupabase) => {
  const { data: cultivo, error } = await sb
    .from('cultivos')
    .update(data)
    .eq('id', id)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) throw error;
  return cultivo;
};

const remove = async (id, userId, sb = defaultSupabase) => {
  const { error } = await sb
    .from('cultivos')
    .delete()
    .eq('id', id)
    .eq('user_id', userId);

  if (error) throw error;
};

const parcelaExists = async (parcelaId, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('parcelas')
    .select('id')
    .eq('id', parcelaId)
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw error;
  return !!data;
};

module.exports = { getAll, getById, create, update, remove, parcelaExists };
