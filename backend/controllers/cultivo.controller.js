const cultivoService = require('../services/cultivo.service');

const requiredFields = ['parcela_id', 'nombre', 'fecha_siembra'];

exports.create = async (req, res, next) => {
  try {
    const missing = requiredFields.filter(
      (f) => req.body[f] === undefined || req.body[f] === null || req.body[f] === '',
    );

    if (missing.length > 0) {
      return res.status(400).json({
        error: true,
        mensaje: `Datos incompletos: ${missing.join(', ')} son requeridos`,
      });
    }

    const sb = req.supabase;
    const exists = await cultivoService.parcelaExists(req.body.parcela_id, req.user.id, sb);
    if (!exists) {
      return res.status(404).json({
        error: true,
        mensaje: `La parcela con id ${req.body.parcela_id} no existe`,
      });
    }

    const cultivo = await cultivoService.create(req.body, req.user.id, sb);
    res.status(201).json(cultivo);
  } catch (err) {
    next(err);
  }
};

exports.getAll = async (req, res, next) => {
  try {
    const cultivos = await cultivoService.getAll(req.user.id, req.query.parcela_id, req.supabase);
    res.status(200).json(cultivos);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ error: true, mensaje: 'ID de cultivo inválido' });
    }

    const sb = req.supabase;
    const existing = await cultivoService.getById(id, req.user.id, sb);
    if (!existing) {
      return res.status(404).json({
        error: true,
        mensaje: `El cultivo con id ${id} no existe`,
      });
    }

    if (req.body.parcela_id !== undefined) {
      const exists = await cultivoService.parcelaExists(req.body.parcela_id, req.user.id, sb);
      if (!exists) {
        return res.status(404).json({
          error: true,
          mensaje: `La parcela con id ${req.body.parcela_id} no existe`,
        });
      }
    }

    const cultivo = await cultivoService.update(id, req.body, req.user.id, sb);
    res.status(200).json(cultivo);
  } catch (err) {
    next(err);
  }
};

exports.delete = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ error: true, mensaje: 'ID de cultivo inválido' });
    }

    const sb = req.supabase;
    const existing = await cultivoService.getById(id, req.user.id, sb);
    if (!existing) {
      return res.status(404).json({
        error: true,
        mensaje: `El cultivo con id ${id} no existe`,
      });
    }

    await cultivoService.remove(id, req.user.id, sb);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};
