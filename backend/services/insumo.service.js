const { supabase: defaultSupabase } = require('../config/db');

const getAll = async (userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('insumos')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data;
};

const getById = async (id, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('insumos')
    .select('*')
    .eq('id', id)
    .eq('user_id', userId)
    .single();

  if (error) throw error;
  return data;
};

const create = async (data, userId, sb = defaultSupabase) => {
  const { data: insumo, error } = await sb
    .from('insumos')
    .insert({ ...data, user_id: userId })
    .select()
    .single();

  if (error) throw error;
  return insumo;
};

const update = async (id, data, userId, sb = defaultSupabase) => {
  const { data: insumo, error } = await sb
    .from('insumos')
    .update(data)
    .eq('id', id)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) throw error;
  return insumo;
};

const remove = async (id, userId, sb = defaultSupabase) => {
  const { error } = await sb
    .from('insumos')
    .delete()
    .eq('id', id)
    .eq('user_id', userId);

  if (error) throw error;
};

const cultivoExists = async (cultivoId, userId, sb = defaultSupabase) => {
  const { data, error } = await sb
    .from('cultivos')
    .select('id')
    .eq('id', cultivoId)
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw error;
  return !!data;
};

module.exports = { getAll, getById, create, update, remove, cultivoExists };