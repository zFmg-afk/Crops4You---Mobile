const actividadService = require('../services/actividadService');

exports.getAll = async (req, res, next) => {
  try {
    const actividades = await actividadService.getAll(req.query.user_id, req.query.cultivo_id);
    res.json(actividades);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const actividad = await actividadService.getById(req.params.id, req.query.user_id);
    res.json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const actividad = await actividadService.create(req.body);
    res.status(201).json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const actividad = await actividadService.update(req.params.id, req.body);
    res.json(actividad);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const result = await actividadService.remove(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
