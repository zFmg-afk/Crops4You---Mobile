const parcelaService = require('../services/parcelaService');

exports.getAll = async (req, res, next) => {
  try {
    const parcelas = await parcelaService.getAll(req.query.user_id);
    res.json(parcelas);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const parcela = await parcelaService.getById(req.params.id, req.query.user_id);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const parcela = await parcelaService.create(req.body);
    res.status(201).json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const parcela = await parcelaService.update(req.params.id, req.body);
    res.json(parcela);
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const result = await parcelaService.remove(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
