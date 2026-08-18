const insumoService = require('../services/insumo.service');

const requiredFields = ['cultivo_id', 'nombre', 'tipo', 'cantidad', 'unidad', 'fecha'];

const validCantidad = (cantidad) =>
  typeof cantidad === 'number' && cantidad > 0;

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

    if (!validCantidad(req.body.cantidad)) {
      return res.status(400).json({
        error: true,
        mensaje: 'La cantidad debe ser un número mayor a cero',
      });
    }

    const sb = req.supabase;
    const exists = await insumoService.cultivoExists(req.body.cultivo_id, req.user.id, sb);
    if (!exists) {
      return res.status(404).json({
        error: true,
        mensaje: `El cultivo con id ${req.body.cultivo_id} no existe`,
      });
    }

    const insumo = await insumoService.create(req.body, req.user.id, sb);
    res.status(201).json(insumo);
  } catch (err) {
    next(err);
  }
};

exports.getAll = async (req, res, next) => {
  try {
    const insumos = await insumoService.getAll(
      req.user.id,
      req.query.cultivo_id,
      req.supabase,
    );
    res.status(200).json(insumos);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ error: true, mensaje: 'ID de insumo inválido' });
    }

    const sb = req.supabase;
    const existing = await insumoService.getById(id, req.user.id, sb);
    if (!existing) {
      return res.status(404).json({
        error: true,
        mensaje: `El insumo con id ${id} no existe`,
      });
    }

    if (req.body.cantidad !== undefined && !validCantidad(req.body.cantidad)) {
      return res.status(400).json({
        error: true,
        mensaje: 'La cantidad debe ser un número mayor a cero',
      });
    }

    if (req.body.cultivo_id !== undefined) {
      const exists = await insumoService.cultivoExists(req.body.cultivo_id, req.user.id, sb);
      if (!exists) {
        return res.status(404).json({
          error: true,
          mensaje: `El cultivo con id ${req.body.cultivo_id} no existe`,
        });
      }
    }

    const insumo = await insumoService.update(id, req.body, req.user.id, sb);
    res.status(200).json(insumo);
  } catch (err) {
    next(err);
  }
};

exports.delete = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ error: true, mensaje: 'ID de insumo inválido' });
    }

    const sb = req.supabase;
    const existing = await insumoService.getById(id, req.user.id, sb);
    if (!existing) {
      return res.status(404).json({
        error: true,
        mensaje: `El insumo con id ${id} no existe`,
      });
    }

    await insumoService.remove(id, req.user.id, sb);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};