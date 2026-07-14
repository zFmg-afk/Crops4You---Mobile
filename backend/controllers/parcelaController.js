const parcelaService = require('../services/parcelaService');

exports.getAll = async (req, res, next) => {
  try {
    const sb = req.supabase;
    const parcelas = await parcelaService.getAll(req.user.id, sb);
    res.json(parcelas);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const sb = req.supabase;
    const parcela = await parcelaService.getById(req.params.id, req.user.id, sb);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const sb = req.supabase;
    if (!req.body.nombre) {
      return res.status(400).json({ error: true, mensaje: 'El nombre es requerido' });
    }
    const body = { ...req.body, user_id: req.user.id };
    const parcela = await parcelaService.create(body, sb);
    res.status(201).json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const sb = req.supabase;
    const parcela = await parcelaService.update(req.params.id, req.body, sb);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const sb = req.supabase;
    const result = await parcelaService.remove(req.params.id, sb);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
