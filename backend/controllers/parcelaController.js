const parcelaService = require('../services/parcelaService');

exports.getAll = async (req, res, next) => {
  try {
    const parcelas = await parcelaService.getAll(req.user.id, req.supabase);
    res.json(parcelas);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const parcela = await parcelaService.getById(req.params.id, req.user.id, req.supabase);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    if (!req.body.nombre) {
      return res.status(400).json({ error: true, mensaje: 'El nombre es requerido' });
    }
    const body = { ...req.body, user_id: req.user.id };
    const parcela = await parcelaService.create(body, req.supabase);
    res.status(201).json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const parcela = await parcelaService.update(req.params.id, req.body, req.supabase);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const result = await parcelaService.remove(req.params.id, req.supabase);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
