const recordatorioService = require('../services/recordatorioService');

exports.getAll = async (req, res, next) => {
  try {
    const recordatorios = await recordatorioService.getAll(
      req.user.id,
      req.query.cultivo_id,
      req.supabase,
    );
    res.json(recordatorios);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const recordatorio = await recordatorioService.getById(
      req.params.id,
      req.user.id,
      req.supabase,
    );
    res.json(recordatorio);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const recordatorio = await recordatorioService.create(req.body, req.user.id, req.supabase);
    res.status(201).json(recordatorio);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const recordatorio = await recordatorioService.update(
      req.params.id,
      req.body,
      req.user.id,
      req.supabase,
    );
    res.json(recordatorio);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const result = await recordatorioService.remove(req.params.id, req.user.id, req.supabase);
    res.json(result);
  } catch (err) {
    next(err);
  }
};