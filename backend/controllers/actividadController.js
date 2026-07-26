const actividadService = require('../services/actividadService');

exports.getAll = async (req, res, next) => {
  try {
    const actividades = await actividadService.getAll(
      req.user.id,
      req.query.cultivo_id,
      req.supabase,
    );
    res.json(actividades);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const actividad = await actividadService.getById(
      req.params.id,
      req.user.id,
      req.supabase,
    );
    res.json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const actividad = await actividadService.create(req.body, req.user.id, req.supabase);
    res.status(201).json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const actividad = await actividadService.update(
      req.params.id,
      req.body,
      req.user.id,
      req.supabase,
    );
    res.json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const result = await actividadService.remove(req.params.id, req.user.id, req.supabase);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
