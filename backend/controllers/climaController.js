const climaService = require('../services/climaService');

exports.getClima = async (req, res, next) => {
  try {
    const { lat, lon } = req.query;
    const clima = await climaService.obtenerClima(lat, lon);
    res.json(clima);
  } catch (err) {
    next(err);
  }
};